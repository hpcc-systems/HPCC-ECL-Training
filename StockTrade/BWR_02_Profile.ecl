IMPORT StockTrade;
IMPORT DataPatterns;

#WORKUNIT('name', 'Stock Data: Profile Cleaned Data');

// Collect the results of the data profiling call
profileResults := DataPatterns.Profile(StockTrade.Files.Cleaned.ds);

// Write results as a native Thor file
OUTPUT(profileResults, /*RecStruct*/, StockTrade.Files.Profiled.PATH, OVERWRITE);
