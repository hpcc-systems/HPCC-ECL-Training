IMPORT StockTrade;
IMPORT DataPatterns;

#WORKUNIT('name', 'Stock Data: Profile Final Data');

// Collect the results of the data profiling call
profileResults := DataPatterns.Profile
    (
        StockTrade.Files.Features.ds,
        features := 'fill_rate,best_ecl_types,cardinality,modes,lengths,patterns,min_max,mean,std_dev,quartiles'
    );

// Write results as a native Thor file
OUTPUT(profileResults, /*RecStruct*/, StockTrade.Files.PATH_PREFIX + '::final_profile', OVERWRITE);
