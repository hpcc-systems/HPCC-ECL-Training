IMPORT NYTaxiTrip.Data_Modules;
IMPORT Data_Modules.Taxi_Weather;
IMPORT NYTaxiTrip.Utils;


#WORKUNIT('NAME', '3_Data_Validation');

//Data Validation:
d := taxi_weather.ds.raw;
taxi_weather_valid := Utils.Validation(d);//244,793,571
OUTPUT(taxi_weather_valid ,,Taxi_Weather.Paths.validate, OVERWRITE); //56,704,772
