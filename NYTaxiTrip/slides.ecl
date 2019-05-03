IMPORT NYTaxitrip.A_data_ingestion AS A;
IMPORT NYTaxiTrip.D_Data_Enhancement AS D;

ds := a.raw;
ds1 := d.enhancedData;
OUTPUT(ds1);
