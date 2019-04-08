/* Shaping with ROLLUP */
/*
   In one way, ROLLUP is used combine related 
   records into a single aggregate record. Think 
   of it as an aggregating SQL self join. 
*/
Layout := RECORD
    STRING10 pickup_date;
    DECIMAL8_2 fare;
    DECIMAL8_2 distance;
    DECIMAL8_2 mileageDeduction := 0;
END;

inputDs := DATASET([{'2015-01-01', 25.10, 5},
               {'2015-01-01', 40.15, 8},
               {'2015-01-02', 30.10, 6},
               {'2015-01-02', 25.15, 4}], Layout);
  
// Rollup (aggregate) data daily
outputDs := ROLLUP(SORT(inputDs, pickup_date), LEFT.pickup_date=RIGHT.pickup_date,
                   TRANSFORM(Layout,
                             SELF.pickup_date := LEFT.pickup_date,
                             SELF.fare :=  LEFT.fare + RIGHT.fare,
                             SELF.distance := LEFT.distance + RIGHT.distance,
                             SELF.mileageDeduction := self.distance * 0.545));

OUTPUT(outputDs);                             


