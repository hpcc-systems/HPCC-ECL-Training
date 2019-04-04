IMPORT NYTaxiTrip.Data_Modules;
IMPORT Data_Modules.Taxi_Weather;
IMPORT NYTaxiTrip.Utils;


#WORKUNIT('NAME', '4_Feature_Engineer');

//Feature Engineer
taxi_weather_valid := Taxi_Weather.ds.validate;
taxi_weather_engineered := Utils.FeatureEngineer(taxi_weather_valid);
OUTPUT(taxi_weather_engineered,,taxi_weather.Paths.engineered,  NAMED('taxi_weather_engineered'), OVERWRITE);