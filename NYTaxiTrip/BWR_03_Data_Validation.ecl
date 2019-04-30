IMPORT STD;

#WORKUNIT('NAME', '3_Data_Validation');

//Reading Taxi_Weather Data
Layout := RECORD
  STD.Date.Date_t date;
  REAL8 precipintensity;
  INTEGER trip_counts;
END;
raw := DATASET('~thor::taxi::traindata', Layout, THOR);

//Data Validation: valide
validSet := raw( date >= 20000101 AND date <=20190501 );
OUTPUT(validSet);
