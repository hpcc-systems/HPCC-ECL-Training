IMPORT STD;
IMPORT NYTaxiTrip.A_Data_Ingestion;

//Reading Taxi_Weather Data
raw := A_Data_Ingestion.raw;

//Data Validation: valide
validSet := raw( date >= 20000101 AND date <=20190501 );
OUTPUT(validSet);
