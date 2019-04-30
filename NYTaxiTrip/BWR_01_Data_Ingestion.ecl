IMPORT STD;

#WORKUNIT('NAME', '1_Data_Ingestion');
//Reading Taxi_Weather Data
Layout := RECORD
  STD.Date.Date_t date;
  REAL8 precipintensity;
  INTEGER trip_counts;
END;

raw := DATASET('~thor::taxi::traindata', Layout, THOR);
OUTPUT(raw);