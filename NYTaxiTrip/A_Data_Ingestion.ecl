IMPORT STD;

//Reading Taxi_Weather Data
EXPORT A_Data_Ingestion := MODULE

EXPORT Layout := RECORD
  STD.Date.Date_t date;
  REAL8 precipintensity;
  INTEGER trip_counts;
END;

EXPORT raw := DATASET('~thor::taxi::traindata', Layout, THOR);

END;
