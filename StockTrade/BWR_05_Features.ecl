IMPORT StockTrade;
IMPORT Std;

#WORKUNIT('name', 'Stock Data: Enhance Cleaned Data With Full Features');

baseData := StockTrade.Files.Enhanced.ds;

// Rewrite the data into the record structure that is needed for ITERATE
enhancedData1 := PROJECT
    (
        baseData,
        TRANSFORM
            (
                StockTrade.Files.Features.Layout,
                SELF := LEFT,
                SELF := []
            )
    );

// Group all records around their full symbol, sorted by trade date
groupedData := GROUP(SORT(enhancedData1, symbol, trade_date), symbol);

// Append new features useful for other analytics on a per-symbol basis
withChanges := ITERATE
    (
        groupedData,
        TRANSFORM
            (
                RECORDOF(LEFT),
                SELF.shares_traded_change_rate := RIGHT.shares_traded_change / LEFT.shares_traded,
                SELF.direction := MAP
                    (
                        RIGHT.closing_price_change < 0 => 0,
                        RIGHT.closing_price_change > 0 => 1,
                        2 // closing price is unchanged
                    ),
                SELF := RIGHT
            )
    );

ungroupedData := UNGROUP(withChanges);

OUTPUT(ungroupedData, /*RecStruct*/, StockTrade.Files.Features.PATH, OVERWRITE, COMPRESSED);
