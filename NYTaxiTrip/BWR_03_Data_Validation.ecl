#WORKUNIT('NAME', '3_Data_Validation');

//Data Validation:
Layout := RECORD
    INTEGER id;
    REAL8   precipitation;
    INTEGER trend;

END;
raw := DATASET('~trainset', Layout, CSV(HEADING(1)));
validset := raw( precipitation >=0 AND precipitation <=1 );
OUTPUT(validset );
