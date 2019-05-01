IMPORT StockTrade.C_Data_Validation;

EXPORT D_Data_Enhancement := MODULE
    //Reading Taxi_Weather Data
    SHARED  validSet := C_Data_Validation.validSet;

    //Enhance raw data
    SHARED  enhancedLayout := RECORD
        INTEGER    id;
        DECIMAL9_2 opening_price;
        DECIMAL9_2 low_price;
        DECIMAL9_2 closing_price;
        DECIMAL9_2 high_price;
        UNSIGNED4  shares_traded;
        DECIMAL9_2 opening_price_change := 0;
        DECIMAL9_2 closing_price_change := 0;
        INTEGER4   shares_traded_change := 0;
        DECIMAL9_2 moving_ave_opening_price := 0;
        DECIMAL9_2 moving_ave_high_price := 0;
        DECIMAL9_2 moving_ave_low_price := 0;
        DECIMAL9_2 moving_ave_closing_price := 0;
        INTEGER4   trend := 0;
        END;

    //Transform the data for ITERATE
    SHARED    sortedData := PROJECT(SORT(validSet, id), TRANSFORM(enhancedLayout, SELF := LEFT));

    //Add Changes
    SHARED    withChanges := ITERATE
            (
                sortedData,
                TRANSFORM
                    (
                        enhancedLayout,
                        SELF.opening_price_change := RIGHT.opening_price - LEFT.opening_price,
                        SELF.closing_price_change := RIGHT.closing_price - LEFT.closing_price,
                        SELF.shares_traded_change := RIGHT.shares_traded - LEFT.shares_traded,
                        SELF.trend := IF(RIGHT.closing_price > LEFT.closing_price, 1, 0);
                        SELF := RIGHT
                    )
            );

    //Add moving averages
    SHARED    withMovingAve := DENORMALIZE
            (
                withChanges,
                withChanges,
                RIGHT.id > 0
                    AND RIGHT.id BETWEEN (LEFT.id - 5) AND (LEFT.id - 1),
                GROUP,
                TRANSFORM
                    (
                        RECORDOF(LEFT),
                        SELF.moving_ave_opening_price := IF(COUNT(ROWS(RIGHT)) = 5, AVE(ROWS(RIGHT), opening_price), 0),
                        SELF.moving_ave_high_price := IF(COUNT(ROWS(RIGHT)) = 5, AVE(ROWS(RIGHT), high_price), 0),
                        SELF.moving_ave_low_price := IF(COUNT(ROWS(RIGHT)) = 5, AVE(ROWS(RIGHT), low_price), 0),
                        SELF.moving_ave_closing_price := IF(COUNT(ROWS(RIGHT)) = 5, AVE(ROWS(RIGHT), closing_price), 0),
                        SELF := LEFT
                    ),
                ALL
            );
    //Export enhanced result
    enhancedLayout1 := RECORD
        INTEGER id;
        decimal9_2 opening_price_change;
        decimal9_2 closing_price_change;
        integer4 shares_traded_change;
        decimal9_2 moving_ave_opening_price;
        decimal9_2 moving_ave_high_price;
        decimal9_2 moving_ave_low_price;
        decimal9_2 moving_ave_closing_price;
        unsigned4 trend;
    END;
    EXPORT enhancedData := PROJECT(withMovingAve(id > 5),TRANSFORM(enhancedLayout1, SELF := LEFT) );
END;