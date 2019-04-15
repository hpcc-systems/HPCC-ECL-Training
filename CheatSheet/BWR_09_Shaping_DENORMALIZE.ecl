/* Denormalize */
/* Combine data from two normalized Datasets */   
WeatherLayout := RECORD 
    STRING10 weather_date;
    UNSIGNED hour_of_day;
    DECIMAL8_2 rain_quantity;
END;
TripLayout := RECORD
    STRING10 pickup_date;
    DECIMAL8_2 fare;
    DECIMAL8_2 distance;
    DATASET(WeatherLayout) weatherDs ;
END;
tripDs := DATASET(
  [{'2015-01-01', 25.10, 5, []},
   {'2015-01-01', 40.15, 8, []},
   {'2015-01-02', 30.10, 6, []},
   {'2015-01-02', 25.15, 4, []}], TripLayout);

weatherDs := DATASET(
    [{'2015-01-01', 1, 0.5},
     {'2015-01-01', 2, 1},
     {'2015-01-02', 1, 0},
     {'2015-01-02', 2, 0}], WeatherLayout);

outputDs := DENORMALIZE(
    tripDs, weatherDs, 
    LEFT.pickup_date=RIGHT.weather_date,
    GROUP,
    TRANSFORM(TripLayout, 
            SELF.pickup_date := LEFT.pickup_date,
            SELF.fare := LEFT.fare,
            SELF.distance := LEFT.distance,
            SELF.weatherDs := ROWS(RIGHT)));
OUTPUT(outputDs); 



