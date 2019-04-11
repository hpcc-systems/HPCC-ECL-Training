/* Combine Datasets */
/* Combine data from two or more Datasets */   
TripLayout := RECORD
    STRING10 pickup_date;
    DECIMAL8_2 distance;
END;

WeatherLayout := RECORD 
    STRING10 weather_date;
    DECIMAL8_2 rain_quantity;
END;

tripDs := DATASET(
  [{'2015-01-01', 11000},
   {'2015-01-02', 12500},
   {'2015-01-03', 11800},
   {'2015-01-04', 13000}], TripLayout);

weatherDs := DATASET(
    [{'2015-01-01', 0.5},
     {'2015-01-02', 1},
     {'2015-01-05', 0},
     {'2015-01-06', 0}], WeatherLayout);


JOIN(tripDs, weatherDs, LEFT.pickup_date=RIGHT.weather_date);//Only those records that exist in both 

JOIN(tripDs, weatherDs, LEFT.pickup_date=RIGHT.weather_date,LEFT OUTER);//At least one record for every record in the left

JOIN(tripDs, weatherDs, LEFT.pickup_date=RIGHT.weather_date,RIGHT OUTER);//At least one record for every record in the right

JOIN(tripDs, weatherDs, LEFT.pickup_date=RIGHT.weather_date,FULL OUTER);//At least one record for every record in the left & right

JOIN(tripDs, weatherDs, LEFT.pickup_date=RIGHT.weather_date,LEFT ONLY);//One record for each left record with no match in the right

JOIN(tripDs, weatherDs, LEFT.pickup_date=RIGHT.weather_date,RIGHT ONLY);//One record for each right record with no match in the left

JOIN(tripDs, weatherDs, LEFT.pickup_date=RIGHT.weather_date,FULL ONLY);//One record for each left and right record with no match in the opposite

 

