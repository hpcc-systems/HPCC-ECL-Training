IMPORT Std;
IMPORT ML_Core;
IMPORT ML_Core.Types;
IMPORT ML_Core.Analysis;
IMPORT NYTaxiTrip.Data_Modules;
IMPORT Data_Modules.Taxi;
IMPORT Data_Modules.Weather;
IMPORT Data_Modules.Taxi_Weather;
IMPORT LogisticRegression AS LR;

EXPORT Utils := MODULE
    EXPORT Constants := MODULE
          EXPORT e := 0.0000000001;
    END;
    //Data Integration
    EXPORT INTEGRATE(DATASET(Taxi.Layouts.raw) t, DATASET(Weather.Layouts.raw) w) := FUNCTION
            preprocess_taxi := PROJECT
            (
                t(tpep_pickup_datetime <> ''),   //Filter out empty data
                TRANSFORM
                (
                    Taxi.Layouts.Preprocess,
                    SELF.date :=
                            Std.Date.FromStringToDate(LEFT.tpep_pickup_datetime[..10], '%Y-%m-%d'),
                    SELF.pickup_time :=
                            Std.Date.FromStringToTime(LEFT.tpep_pickup_datetime[12..], '%H:%M:%S'),
                    SELF.pickup_minutes_after_midnight:= Std.Date.Hour(SELF.pickup_time)
                            * 60 + Std.Date.Minute(SELF.pickup_time);
                )
            );

            taxi_weather := JOIN
            (
                preprocess_taxi,
                w,
                LEFT.date = RIGHT.date AND
                RIGHT.minutes_after_midnight BETWEEN
                LEFT.pickup_minutes_after_midnight - 30 AND
                LEFT.pickup_minutes_after_midnight + 30,
                TRANSFORM
                (
                    Taxi_Weather.Layouts.raw,
                    SELF.date:= RIGHT.date,
                    SELF.minutes_after_midnight := RIGHT.minutes_after_midnight,
                    SELF.summary := RIGHT.summary,
                    SELF.temperature := RIGHT.temperature,
                    SELF.precipIntensity := RIGHT.precipIntensity,
                    SELF.precipType := RIGHT.precipType,
                    SELF.windSpeed := RIGHT.windSpeed,
                    SELF.visibility := RIGHT.visibility,
                    SELF.cloudCover := RIGHT.cloudCover,
                    SELF := LEFT
                ),
                LEFT OUTER
            );
            ML_Core.AppendSeqid(taxi_weather, id, result);
            RETURN result;
    END;
    //Data Validation
    EXPORT Validation(DATASET(Taxi_Weather.Layouts.raw) tw) := FUNCTION
            SET OF STRING summaries := ['Breezy', 'Clear', 'Possible', 'Snow', 'Windy', '', 'Mostly',
                            'Heavy', 'Humid', 'Overcast', 'Foggy', 'Light', 'Partly', 'Rain'];
            preValid :=PROJECT(tw, TRANSFORM(Taxi_Weather.Layouts.Validate,
                                SELF.isValidDate := IF( LEFT.date >= 20150101 AND LEFT.date <= 20160631, TRUE, FALSE),
                                SELF.isValidminutes_after_midnight  := IF( LEFT.minutes_after_midnight >=0 AND LEFT.minutes_after_midnight <=1440, TRUE, FALSE),
                                SELF.isValidSummary   := IF( LEFT.summary IN summaries, TRUE, FALSE),
                                SELF.isValidTemp  := IF( LEFT.temperature >= -50 AND LEFT.temperature <= 150, TRUE, FALSE) ,
                                SELF.isValidPrecipIntensity  :=IF( LEFT.precipIntensity >=0 AND LEFT.precipIntensity <= 100, TRUE, FALSE),
                                SELF.isValidPrecipType  :=IF( LEFT.precipType = '' OR LEFT.precipType = 'rain' OR LEFT.precipType = 'snow', TRUE, FALSE) ,
                                SELF.isValidWindSpeed   :=IF( LEFT.windSpeed >= 0 AND LEFT.windSpeed <= 100, TRUE, FALSE) ,
                                SELF.isValidVisibility  :=IF( LEFT.visibility >= 0 AND LEFT.windSpeed <= 35, TRUE, FALSE),
                                SELF.isValidCloudCover  := IF( LEFT.visibility >= 0 AND LEFT.windSpeed <= 1, TRUE, FALSE),
                                SELF := LEFT));
        filtered := preValid(isValidDate = TRUE AND isValidminutes_after_midnight = TRUE AND isValidSummary = TRUE
                        AND  isValidTemp = TRUE AND isValidPrecipIntensity = TRUE AND isValidWindSpeed = TRUE
                        AND  isValidVisibility = TRUE AND isValidCloudCover = TRUE);
        RETURN filtered;
    END;
    //FEATURE Engineer
    EXPORT FeatureEngineer(DATASET(Taxi_Weather.Layouts.validate) tw) := FUNCTION
            features := PROJECT(tw,
            TRANSFORM(
            Taxi_weather.Layouts.features,
            SELF.weather := MAP(
                                LEFT.summary = 'Overcast' => 1,
                                LEFT.summary ='Heavy'    => 1,
                                LEFT.summary ='Humid'    => 1,
                                LEFT.summary ='Foggy'    => 1,
                                LEFT.summary ='Rain'     => 1,
                                0
                                ),
            SELF := LEFT)
            );
            g_features := GROUP(features, date, ALL);
            Taxi_Weather.Layouts.features take(Taxi_Weather.Layouts.features le,
                                                DATASET(Taxi_Weather.Layouts.features) ri) := TRANSFORM
            SELF.totaltrips := COUNT(ri),
            SELF.weather := SUM(ri, weather),
            SELF.temperature := SUM(ri, temperature)/SELF.totaltrips,
            SELF.precipIntensity := SUM(ri, precipIntensity)/SELF.totaltrips,
            SELF.windSpeed := SUM(ri, windSpeed)/SELF.totaltrips,
            SELF.visibility := SUM(ri, visibility)/SELF.totaltrips,
            SELF.cloudCover := SUM(ri, cloudCover)/SELF.totaltrips,
            SELF := le;
            END;
            r_features := ROLLUP(g_features, GROUP, take(LEFT, ROWS(LEFT)));
            engineered := ITERATE(
                        SORT(r_features, date),
                        TRANSFORM(Taxi_Weather.Layouts.features,
                        SELF.date := RIGHT.date,
                        SELF.weather_change := RIGHT.weather - LEFT.weather,
                        SELF.temperature_change := (RIGHT.temperature - LEFT.temperature)/(LEFT.temperature),
                        SELF.precipIntensity_change :=  (RIGHT.precipIntensity - LEFT.precipIntensity)/LEFT.precipIntensity,
                        SELF.windSpeed_change := (RIGHT.windSpeed - LEFT.windSpeed)/LEFT.windSpeed,
                        SELF.visibility_change := (RIGHT.visibility - LEFT.visibility)/LEFT.visibility,
                        SELF.cloudCover_change := (RIGHT.cloudCover - LEFT.cloudCover)/LEFT.cloudCover,
                        SELF.totaltrips_change := RIGHT.totaltrips - LEFT.totaltrips;
                        SELF.trend := IF(SELF.totaltrips_change >= 0, 1, 0);
                        SELF := RIGHT,
                        ));
            result := PROJECT(engineered(cloudCover_change <>0 AND precipIntensity_change <> 0 AND visibility_change <>0 ), TRANSFORM(Taxi_Weather.Layouts.engineered, SELF := LEFT;));
            RETURN result;
    END;
    //Logistic Regression
    EXPORT logisticModel(INTEGER max_iter, REAL t) := MODULE
       EXPORT preML(DATASET(Taxi_Weather.Layouts.engineered) ds, INTEGER a = 1, INTEGER b = 1) := FUNCTION
            //Random Sampling
            addRdm := PROJECT(ds, TRANSFORM({RECORDOF(ds), REAL rm},
                            SELF.rm := RANDOM(), SELF := LEFT));
            sp := ENTH(SORT(addRdm, rm), a, b, 1);
            RETURN PROJECT(sp, TRANSFORM(Taxi_Weather.Layouts.engineered, SELF := LEFT));
        END;
        SHARED m_bi := LR.BinomialLogisticRegression(max_iter, t);
        SHARED pnumber := 4;
        //fit trainset
        EXPORT fit(DATASET(Taxi_Weather.Layouts.engineered) tw) := FUNCTION
            //Prepare trainset
            sptrain:= preML(tw, 4, 5);
            //Transform to NF format.
            ML_Core.ToField(sptrain, train, id);
            //Trainset
            train_Ind := train(number< pnumber );
            train_Dpt := PROJECT(train(number = pnumber  ), TRANSFORM(Types.DiscreteField, SELF.number := 1, SELF := LEFT));
            //Fit the data
            mod_bi := m_bi.getModel(train_ind, train_dpt);
            RETURN mod_bi;
        END;
        //Predict
        EXPORT predict(DATASET(Types.Layout_Model) m,
                        DATASET(Taxi_Weather.Layouts.engineered) tw) := FUNCTION
            //Prepare testset
            sptest:= preML(tw, 1, 5);
            //Transform to NF format.
            ML_Core.ToField(sptest, test, id);
                    //Testset
            test_Ind := test(number < pnumber );
            test_Dpt :=  PROJECT(test(number = pnumber  ), TRANSFORM(Types.DiscreteField,  SELF.number := 1, SELF := LEFT));
            //Test the model
            predict_bi := m_bi.Classify(m,  test_Ind);
            //Evaluate the model
            evaluation := Analysis.Classification.AccuracyByClass(predict_bi, test_dpt);
            o := OUTPUT(evaluation, NAMED('evaluation'));
            RETURN WHEN(predict_bi,o);
        END;
    END;
END;