#WORKUNIT('NAME', '1_Data_Ingestion');

//Reading Taxi_Weather Data
Layout := RECORD
    INTEGER id;
    REAL8   precipitation;
    INTEGER trend;

END;
raw := DATASET('~trainset', Layout, CSV(HEADING(1)));
OUTPUT(raw);