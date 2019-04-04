//**** Group Data

//ECL provides functions to aggregate grouped data

Layout := RECORD
    STRING10 pickup_date;
    DECIMAL8_2 fare;
    DECIMAL8_2 distance;
END;

ds := DATASET([{'2015-01-01', 25.10, 5},
               {'2015-01-01', 40.15, 8},
               {'2015-01-02', 30.10, 6},
               {'2015-01-02', 25.15, 4}], Layout);

crossTabLayout := RECORD 
   ds.pickup_date;
   avgFare := AVE(GROUP, ds.fare);
   totalFare := SUM(GROUP, ds.fare);
   varianceFare := VARIANCE(GROUP, ds.fare);
   coVarianceFareDist := COVARIANCE(GROUP, ds.fare, ds.distance);
   correlateFareDist := CORRELATION(GROUP, ds.fare, ds.distance);
END;

crossTabDs := TABLE(ds, crossTabLayout, pickup_date);
OUTPUT(crossTabDs);
