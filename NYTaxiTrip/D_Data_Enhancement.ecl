IMPORT STD;
IMPORT DataPatterns;
IMPORT NYTaxiTrip.A_Data_Ingestion;

EXPORT D_Data_Enhancement := MODULE
//Reading Taxi_Weather Data
SHARED raw := A_Data_Ingestion.raw;

//Enhance raw data
EXPORT enhancedLayout := RECORD
  INTEGER id;
  INTEGER month_of_year;
  INTEGER day_of_week;
  REAL8   precipintensity;
  INTEGER trip_counts;
END;

EXPORT enhancedData := PROJECT(raw, TRANSFORM(enhancedLayout,
                                        SELF.id := COUNTER,
                                        SELF.day_of_week := (INTEGER) Std.Date.DayOfWeek(LEFT.date),
                                        SELF.month_of_year := (INTEGER) LEFT.date[5..6],
                                        SELF.precipintensity := LEFT.precipintensity,
                                        SELF.trip_counts := LEFT.trip_counts));
END;