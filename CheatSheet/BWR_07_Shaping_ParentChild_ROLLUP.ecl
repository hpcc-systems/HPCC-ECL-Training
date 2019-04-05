InputLayout := RECORD
    STRING10 pickup_date;
    DECIMAL8_2 fare;
    DECIMAL8_2 distance;
END;

OutputLayout := RECORD
    STRING10 pickup_date;
    DATASET(InputLayout) trips;
END;

inputDs := DATASET([{'2015-01-01', 25.10, 5},
               {'2015-01-01', 40.15, 8},
               {'2015-01-02', 30.10, 6},
               {'2015-01-02', 25.15, 4}], InputLayout);

groupDs := GROUP(SORT(inputDs, pickup_date), pickup_date);

tempDs := ROLLUP(groupDs, GROUP, TRANSFORM(OutputLayout, 
                                           SELF.pickup_date := LEFT.pickup_date,
                                           SELF.trips := ROWS(LEFT)));    

OUTPUT(tempDs);                                                      