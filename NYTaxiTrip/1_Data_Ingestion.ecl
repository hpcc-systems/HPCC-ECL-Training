IMPORT NYTaxiTrip.Data_Modules;
IMPORT Data_Modules.Taxi;
IMPORT Data_Modules.Weather;
IMPORT Data_Modules.Taxi_Weather;
IMPORT NYTaxiTrip.Utils;

#WORKUNIT('NAME', '1_Data_Ingestion');

//Import the Source Datasets
//Taxi Data
Taxi_raw := Taxi.ds.raw;
//Weather Data
Weather_raw := Weather.ds.raw;

//Integrate the Source Datasets
taxi_weather_raw := Utils.INTEGRATE(Taxi_raw, Weather_raw);
OUTPUT(taxi_weather_raw,,Taxi_Weather.Paths.raw, COMPRESSED, OVERWRITE);