IMPORT STD;

#WORKUNIT('NAME', '2_Data_Enhancement');
//Reading Taxi_Weather Data
Layout := RECORD
  STD.Date.Date_t date;
  REAL8 precipintensity;
  INTEGER trip_counts;
END;
raw := DATASET('~thor::taxi::traindata', Layout, THOR);

//Enhance raw data
enhancedLayout := RECORD
  Layout;
  INTEGER month_of_year;
  INTEGER day_of_week;
END;

enhancedData := PROJECT(raw, TRANSFORM(enhancedLayout,
                                        SELF.date := LEFT.date,
                                        SELF.day_of_week := (INTEGER) Std.Date.DayOfWeek(LEFT.date),
                                        SELF.month_of_year := (INTEGER) SELF.date[5..6],
                                        SELF.precipintensity := LEFT.precipintensity,
                                        SELF.trip_counts := LEFT.trip_counts));

OUTPUT(enhancedData);
