/* Observe Subset */
/*
    Select a subset of rows in a 
    dataset for observation
*/

Layout := RECORD
    STRING10 pickup_date;
    DECIMAL8_2 fare;
    DECIMAL8_2 distance;
END;

ds := DATASET([{'2015-01-01', 25.10, 5},
               {'2015-01-01', 40.15, 8},
               {'2015-01-02', 30.10, 6},
               {'2015-01-02', 25.15, 4}], Layout);

//Filter records by fields
filterDs :=  ds(pickup_date='2015-01-01');
//Remove duplicate records
dedupDs := DEDUP(SORT(ds, pickup_date), pickup_date);
//Returns the top N records
choosenDs := CHOOSEN(ds, 2);//Return the top 2 decords
//Return the top N records after sorting
topDs := TOPN(ds, 2, pickup_date);
//Return a sample part of the dataset
sampleDs := SAMPLE(ds, 2, 1);//return every 2nd record
//Return a sample set of records
enthDs := ENTH(ds, 1, 2, 1);//1 out of every 2

OUTPUT(filterDs);
OUTPUT(dedupDs);
OUTPUT(topDs);
OUTPUT(sampleDs);
OUTPUT(enthDs);

