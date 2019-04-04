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

/*
Find the average number of shares traded per week day.  This is equivalent to
the following SQL statement:

    SELECT trade_day_of_week, AVE(shares_traded) AS num_shares_traded
    FROM theData
    GROUP BY trade_day_of_week;
*/
aveSharesTradedPerDay := TABLE
    (
        theData,
        {
            trade_day_of_week,
            UNSIGNED6   num_shares_traded := AVE(GROUP, shares_traded)
        },
        trade_day_of_week
    );

// Make sure the result is in ascending order by day of week
sortedResult := SORT(aveSharesTradedPerDay, trade_day_of_week);

OUTPUT(sortedResult, NAMED('shares_traded_per_day'));
