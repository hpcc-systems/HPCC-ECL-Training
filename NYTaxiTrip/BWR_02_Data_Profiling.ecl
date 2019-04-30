IMPORT DataPatterns;
IMPORT STD;

#WORKUNIT('NAME', '2_Data_Profiling');

//Reading Taxi_Weather Data
Layout := RECORD
  STD.Date.Date_t date;
  REAL8 precipintensity;
  INTEGER trip_counts;
END;
raw := DATASET('~thor::taxi::traindata', Layout, THOR);

//Data Profiling
Taxi_Weather_profile:= DataPatterns.Profile(raw);
OUTPUT(Taxi_Weather_profile);