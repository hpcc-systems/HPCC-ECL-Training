IMPORT DataPatterns;
IMPORT StockTrade.A_Data_Ingestion;

//Reading Taxi_Weather Data
raw := A_Data_Ingestion.raw;

//Data Profiling
StockData_profile:= DataPatterns.Profile(raw);
OUTPUT(StockData_profile);