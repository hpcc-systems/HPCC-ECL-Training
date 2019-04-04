IMPORT StockTrade;

#WORKUNIT('name', 'Stock Data: Clean Raw Data');

// Reference to original tab-delimited file; uses a record layout with
// explicit, correct datatypes for each field (HPCC automatically coerces)
reinterpretedData := DATASET
    (
        StockTrade.Files.Raw.PATH,
        StockTrade.Files.Cleaned.Layout,
        CSV(SEPARATOR('\t'), HEADING(1), QUOTE(''))
    );

// Write the result as a native Thor logical file
OUTPUT(reinterpretedData, /*RecStruct*/, StockTrade.Files.Cleaned.PATH, OVERWRITE, COMPRESSED);
