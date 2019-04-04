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

// Show the first 100 records in the file
OUTPUT(theData, NAMED('data_sample'));

// Show the first 100 trade days for IBM
OUTPUT(theData(symbol = 'NYSE:IBM'), NAMED('ibm_trades_sample'));

// Show the number of records in the file
recordCount := COUNT(theData);
OUTPUT(recordCount, NAMED('number_of_records'));

// Show the maximum number of shares traded in any single day
maxShares := MAX(theData, shares_traded);
OUTPUT(maxShares, NAMED('max_shares_traded'));

// Show the minimum number of shares (above zero) traded in any single day
minShares := MIN(theData(shares_traded > 0), shares_traded);
OUTPUT(minShares, NAMED('min_shares_traded'));
