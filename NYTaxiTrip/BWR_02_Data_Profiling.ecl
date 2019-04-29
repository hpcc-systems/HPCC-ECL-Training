IMPORT DataPatterns;

#WORKUNIT('NAME', '2_Data_Profiling');

//Data Profiling
Layout := RECORD
    INTEGER id;
    REAL8   precipitation;
    INTEGER trend;

END;
raw := DATASET('~trainset', Layout, CSV(HEADING(1)));
Taxi_Weather_profile:= DataPatterns.Profile(raw);
OUTPUT(Taxi_Weather_profile);