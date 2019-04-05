IMPORT NYTaxiTrip.Files;
IMPORT Files.Taxi_Weather;
IMPORT DataPatterns;

#WORKUNIT('NAME', '2_Data_Profiling');

//Data Profiling
Taxi_Weather_raw := Taxi_Weather.ds.raw;
Taxi_Weather_profile:= DataPatterns.Profile(Taxi_Weather_Raw);
OUTPUT(Taxi_Weather_profile,, Taxi_Weather.Paths.profile, OVERWRITE);