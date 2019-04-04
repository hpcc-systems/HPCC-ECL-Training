// Record definition describing the data
DataRec := RECORD
    UNSIGNED4       trade_date;
    STRING1         exchange_code;
    STRING9         stock_symbol;
    DECIMAL9_2      opening_price;
    DECIMAL9_2      high_price;
    DECIMAL9_2      low_price;
    DECIMAL9_2      closing_price;
    UNSIGNED4       shares_traded;
    UNSIGNED4       share_value;
    STRING16        symbol;
    UNSIGNED2       trade_year;
    UNSIGNED1       trade_month;
    UNSIGNED1       trade_day;
    UNSIGNED1       trade_day_of_week;
    UNSIGNED1       trade_quarter;
    UNSIGNED1       trade_day_of_year;
    UNSIGNED1       trade_day_of_quarter;
    DECIMAL9_2      opening_price_change;
    DECIMAL9_2      closing_price_change;
    INTEGER4        shares_traded_change;
    DECIMAL9_2      moving_ave_opening_price;
    DECIMAL9_2      moving_ave_high_price;
    DECIMAL9_2      moving_ave_low_price;
    DECIMAL9_2      moving_ave_closing_price;
    UNSIGNED8       id;
    REAL4           shares_traded_change_rate;
    UNSIGNED4       direction;
END;

// Reference to the data
theData := DATASET
    (
        '~stock_data::full_data',
        DataRec,
        FLAT
    );

//------------------------------------------------------------------------------

/*
Get the date (with year) and closing price of all Apple trades, put them in
order by date, then add a unique numeric identifier to the record
*/

appleTrades := theData(symbol = 'NASDAQ:AAPL');

sortedTrades := SORT(appleTrades, trade_date);

withID := PROJECT
    (
        sortedTrades,
        TRANSFORM
            (
                {
                    UNSIGNED6   id,
                    DataRec.trade_date,
                    DataRec.trade_year,
                    DataRec.closing_price
                },
                SELF.id := COUNTER,
                SELF := LEFT
            )
    );

OUTPUT(withID, NAMED('sample_aapl_closing_prices'));

//------------------------------------------------------------------------------

// Compute the mean and std deviation for the closing price on a yearly basis
closingStats := TABLE
    (
        withID,
        {
            trade_year,
            DECIMAL9_2      closing_price_mean := AVE(GROUP, closing_price),
            DECIMAL9_2      closing_price_std_dev := SQRT(VARIANCE(GROUP, closing_price))
        },
        trade_year,
        MERGE
    );

OUTPUT(closingStats, NAMED('closingStats'));

// Append a field that shows the closing price as relative to the mean for
// that year
withStats := JOIN
    (
        withID,
        closingStats,
        LEFT.trade_year = RIGHT.trade_year,
        TRANSFORM
            (
                {
                    RECORDOF(LEFT),                             // Copy all fields from 'withID' dataset
                    DECIMAL9_2      relative_closing_price      // New field
                },
                SELF.relative_closing_price := (LEFT.closing_price - RIGHT.closing_price_mean) / RIGHT.closing_price_std_dev,
                SELF := LEFT
            ),
        LOOKUP
    );

// Output 1000 records of the results, not just 100
OUTPUT(CHOOSEN(withStats, 1000), NAMED('closing_prices'));
