IMPORT DataPatterns;
IMPORT NYTaxiTrip.A_Data_Ingestion;

//Reading Taxi_Weather Data
raw := A_Data_Ingestion.raw;

//Data Profiling
Taxi_Weather_profile:= DataPatterns.Profile(raw);
OUTPUT(Taxi_Weather_profile);