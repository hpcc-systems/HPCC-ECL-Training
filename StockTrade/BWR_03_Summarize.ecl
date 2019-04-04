IMPORT StockTrade;
IMPORT Std;

#WORKUNIT('name', 'Stock Data: Summarize Cleaned Data');

// Append a 'symbol' field that contains the stock exchange code and stock
// symbol code in <exchange>:<symbol> format
baseData := PROJECT
    (
        StockTrade.Files.Cleaned.ds,
        TRANSFORM
            (
                {
                    STRING16    symbol,
                    RECORDOF(LEFT)
                },
                SELF.symbol := StockTrade.Util.MakeFullSymbol(LEFT.exchange_code, LEFT.stock_symbol),
                SELF := LEFT
            )
    );

// Compute some stats on a per-symbol basis
perSymbol := TABLE
    (
        baseData,
        {
            symbol,
            Std.Date.Date_t     first_seen_date := MIN(GROUP, trade_date),
            Std.Date.Date_t     last_seen_date := MAX(GROUP, trade_date),
            UNSIGNED4           num_trading_days := COUNT(GROUP),
            DECIMAL9_2          lowest_closing_price := MIN(GROUP, closing_price),
            DECIMAL9_2          highest_closing_price := MAX(GROUP, closing_price)
        },
        symbol,
        MERGE
    );

OUTPUT(perSymbol, /*RecStruct*/, StockTrade.Files.Summarized.PATH, OVERWRITE);
