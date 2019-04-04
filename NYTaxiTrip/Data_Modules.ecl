IMPORT STD;
IMPORT ML_Core.Types;

EXPORT Data_Modules := MODULE
    //Taxi Data
    EXPORT Taxi := MODULE
        //Define Layouts
        EXPORT Layouts := MODULE
            EXPORT raw := RECORD
                STRING  VendorID;                   // Franchisee ID (?)
                STRING  tpep_pickup_datetime;
                STRING  tpep_dropoff_datetime;
                STRING  passenger_count;
                STRING  trip_distance;              // Scale:  miles
                STRING  pickup_longitude;
                STRING  pickup_latitude;
                STRING  rate_code_id;
                STRING  store_and_fwd_flag;         // Y/N
                STRING  dropoff_longitude;
                STRING  dropoff_latitude;
                STRING  payment_type;               // 1 = credit; 2 = cash; there are others
                STRING  fare_amount;
                STRING  extra;
                STRING  mta_tax;
                STRING  tip_amount;
                STRING  tolls_amount;
                STRING  improvement_surcharge;
                STRING  total_amount;
            END;
            EXPORT preprocess := RECORD
                Std.Date.Date_t    date;
                Std.Date.Time_t    pickup_time;
                UNSIGNED2 pickup_minutes_after_midnight;
            END;
        END;
        //Define Paths
        SHARED Prefix := 'taxi_data::raw';
        EXPORT Paths := MODULE
            EXPORT raw := '~' + Prefix +'{'
                    + '::yellow_tripdata_2015-01.csv,'
                    + '::yellow_tripdata_2015-01.csv,'
                    + '::yellow_tripdata_2015-01.csv,'
                    + '::yellow_tripdata_2015-02.csv,'
                    + '::yellow_tripdata_2015-03.csv,'
                    + '::yellow_tripdata_2015-04.csv,'
                    + '::yellow_tripdata_2015-05.csv,'
                    + '::yellow_tripdata_2015-06.csv,'
                    + '::yellow_tripdata_2015-07.csv,'
                    + '::yellow_tripdata_2015-08.csv,'
                    + '::yellow_tripdata_2015-09.csv,'
                    + '::yellow_tripdata_2015-10.csv,'
                    + '::yellow_tripdata_2015-11.csv,'
                    + '::yellow_tripdata_2015-12.csv,'
                    + '::yellow_tripdata_2016-01.csv,'
                    + '::yellow_tripdata_2016-02.csv,'
                    + '::yellow_tripdata_2016-03.csv,'
                    + '::yellow_tripdata_2016-04.csv,'
                    + '::yellow_tripdata_2016-05.csv,'
                    + '::yellow_tripdata_2016-06.csv'
                    + '}';
        END;
        //Define Datasets
        EXPORT ds := MODULE
            EXPORT raw :=  DATASET(Paths.raw, Layouts.raw, CSV(HEADING(1)));
        END;
    END;
    //Sample One Month Taxi Data
    EXPORT Samples := MODULE
        EXPORT Prefix := '~sample';
        EXPORT Paths := MODULE
            EXPORT raw := '~yellow_tripdata_2016-06.csv';
            EXPORT preprocess := prefix + '_preprocess';
        END;
        EXPORT ds := MODULE
            EXPORT raw := DATASET(Paths.raw, Taxi.Layouts.raw, CSV(HEADING(1)));
            EXPORT preprocess := DATASET(Paths.preprocess,Taxi.Layouts.preprocess, THOR);
        END;
    END;
    //Weather data
    EXPORT Weather := MODULE
        //Define Layouts
        EXPORT Layouts := MODULE
            EXPORT raw := RECORD
                Std.Date.Date_t         date;
                Std.Date.Seconds_t      minutes_after_midnight;
                STRING                  summary;                // 1 Breezy; 2	Clear; 3 Possible; 4 Snow; 5 Windy; 6 ''; 7	Mostly;
                                                                // 8 Heavy; 9 Humid; 10 Overcast;11	Foggy; 12 Light; 13	Partly; 14 Rain
                DECIMAL6_3              temperature;            // Fahrenheit
                UDECIMAL6_3             precipIntensity;        // [0.00, 92.03]
                STRING                  precipType;             // '', 'SNOW' , 'RAIN'
                UDECIMAL4_2             windSpeed;              // MPH [0.00 - 87.75]
                UDECIMAL4_2             visibility;             // Miles [0.00 - 20.23]
                UDECIMAL4_2             cloudCover;             // [0.00 - 1.00]
            END;
        END;
        //Define Paths
        EXPORT Paths := MODULE
            EXPORT raw := '~taxi_data::weather_newyork_clean';
        END;
        //Define Datasets
        EXPORT ds := MODULE
            EXPORT raw :=  DATASET(Paths.raw, Layouts.raw, CSV(HEADING(1)));
        END;
    END;
    //Taxi_Weather data
    EXPORT Taxi_Weather := MODULE
        EXPORT Prefix := '~taxi_weather';
        //Define Layouts
        EXPORT Layouts := MODULE
            EXPORT raw := RECORD
                Types.t_RecordID id := 0;
                Weather.Layouts.raw;
            END;
            EXPORT validate := RECORD
                raw;
                BOOLEAN isValidDate;
                BOOLEAN isValidminutes_after_midnight;
                BOOLEAN isValidSummary;
                BOOLEAN isValidTemp;
                BOOLEAN isValidPrecipIntensity;
                BOOLEAN isValidPrecipType;
                BOOLEAN isValidWindSpeed;
                BOOLEAN isValidVisibility;
                BOOLEAN isValidCloudCover;
            END;
            EXPORT features := RECORD
                raw.id;
                raw.date;
                Types.t_Discrete weather;               // 0 -> Good weather; 1 -> Bad weather
                raw.temperature;                        // Fahrenheit
                raw.precipIntensity;                    // [0.00, 92.03]
                raw.windSpeed;                          // MPH [0.00 - 87.75]
                raw.visibility;                         // Miles [0.00 - 20.23]
                raw.cloudCover;                         // [0.00 - 1.00]
                INTEGER totaltrips := 0;
                INTEGER weather_change := 0;
                REAL temperature_change :=0;
                REAL precipIntensity_change :=0;
                REAL windSpeed_change :=0;
                REAL visibility_change :=0;
                REAL cloudCover_change :=0;
                INTEGER totaltrips_change := 0;
                Types.t_Discrete trend := 0;
            END;
            EXPORT engineered := RECORD
                raw.id;
                features.precipIntensity_change;        // [0.00, 92.03]
                features.visibility_change;             // Miles [0.00 - 20.23]
                features.cloudCover_change;             // [0.00 - 1.00]
                features.trend;                         // 0 --> decrease; 1 -> increase
            END;
        END;
        //Define Paths
        EXPORT Paths := MODULE
            EXPORT raw := prefix + '_raw';
            EXPORT profile := prefix + '_profile';
            EXPORT preValid := prefix + '_preValid';
            EXPORT validate := prefix + '_valid';
            EXPORT features := prefix + '_features';
            EXPORT engineered := prefix + '_engineered';
        END;
        //Define Datasets
        EXPORT ds := MODULE
            EXPORT raw := DATASET(Paths.raw, Layouts.raw, FLAT);
            EXPORT preValid := DATASET(Paths.preValid, Layouts.validate, FLAT);
            EXPORT validate := DATASET(Paths.validate, Layouts.validate, FLAT);
            EXPORT features := DATASET(Paths.features, Layouts.features, FLAT);
            EXPORT engineered := DATASET(Paths.engineered, Layouts.engineered, FLAT);
        END;
    END;
    //Sample_Weather data
    EXPORT Sample_Weather := MODULE
        EXPORT Prefix := '~sample_weather';
        //Define Layouts
        EXPORT Layouts := MODULE
            EXPORT raw := RECORD
                Types.t_RecordID id := 0;
                Weather.Layouts.raw;
            END;
            EXPORT validate := RECORD
                raw;
                BOOLEAN isValidDate;
                BOOLEAN isValidminutes_after_midnight;
                BOOLEAN isValidSummary;
                BOOLEAN isValidTemp;
                BOOLEAN isValidPrecipIntensity;
                BOOLEAN isValidPrecipType;
                BOOLEAN isValidWindSpeed;
                BOOLEAN isValidVisibility;
                BOOLEAN isValidCloudCover;
            END;
            EXPORT features := RECORD
                raw.id;
                raw.date;
                Types.t_Discrete weather;               // 0 -> Good weather; 1 -> Bad weather
                raw.temperature;                        // Fahrenheit
                raw.precipIntensity;                    // [0.00, 92.03]
                raw.windSpeed;                          // MPH [0.00 - 87.75]
                raw.visibility;                         // Miles [0.00 - 20.23]
                raw.cloudCover;                         // [0.00 - 1.00]
                INTEGER totaltrips := 0;
                INTEGER weather_change := 0;
                REAL temperature_change :=0;
                REAL precipIntensity_change :=0;
                REAL windSpeed_change :=0;
                REAL visibility_change :=0;
                REAL cloudCover_change :=0;
                INTEGER totaltrips_change := 0;
                Types.t_Discrete trend := 0;
            END;
            EXPORT engineered := RECORD
                raw.id;
                features.precipIntensity_change;        // [0.00, 92.03]
                features.visibility_change;             // Miles [0.00 - 20.23]
                features.cloudCover_change;             // [0.00 - 1.00]
                features.trend;                         // 0 --> decrease; 1 -> increase
            END;
        END;
        //Define Paths
        EXPORT Paths := MODULE
            EXPORT raw := prefix + '_raw';
            EXPORT profile := prefix + '_profile';
            EXPORT preValid := prefix + '_preValid';
            EXPORT validate := prefix + '_valid';
            EXPORT features := prefix + '_features';
            EXPORT engineered := prefix + '_engineered';
        END;
        //Define Datasets
        EXPORT ds := MODULE
            EXPORT raw := DATASET(Paths.raw, Layouts.raw, FLAT);
            EXPORT preValid := DATASET(Paths.preValid, Layouts.validate, FLAT);
            EXPORT validate := DATASET(Paths.validate, Layouts.validate, FLAT);
            EXPORT features := DATASET(Paths.features, Layouts.features, FLAT);
            EXPORT engineered := DATASET(Paths.engineered, Layouts.engineered, FLAT);
        END;
    END;
END;
