IMPORT Std;

InputLayout := RECORD
    STRING pickup_datetime;
    DECIMAL8_2 fare;
    DECIMAL8_2 distance;
END;

OutputLayout := RECORD
    Std.Date.Date_t pickup_date;
    Std.Date.Time_t pickup_time;
    DECIMAL8_2 fare;
    DECIMAL8_2 distance;
END;

inputDs := DATASET([{'2015-01-01 10:00:00', 25.10, 5},
               {'2015-01-01 11:00:00', 40.15, 8},
               {'2015-01-02 10:00:00', 30.10, 6},
               {'2015-01-02 11:00:00', 25.15, 4}], InputLayout);


outputDs := PROJECT(inputDs, TRANSFORM(OutputLayout,
                              SELF.pickup_date := Std.Date.FromStringToDate(LEFT.pickup_datetime[..10], '%Y-%m-%d'),
                              SELF.pickup_time := Std.Date.FromStringToTime(LEFT.pickup_datetime[12..], '%H:%M:%S'),
                              SELF.fare := LEFT.fare,   
                              SELF.distance := LEFT.distance));   
OUTPUT(outputDs);