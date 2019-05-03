IMPORT Visualizer;

Layout := RECORD
    STRING10 pickup_date;
    DECIMAL8_2 fare;
END;

ds := DATASET([{'20150101', 25.10},
               {'20150102', 40.15},
               {'20150103', 30.10},
               {'20150104', 25.15}], Layout);


//  Output dataset giving it a "known" name so the visualization can locate the data
OUTPUT(ds, NAMED('TripViz'));

//  Create the visualization, giving it a uniqueID "bubble" and supplying the result name "TripViz"
Visualizer.TwoD.Bubble('bubble', /*datasource*/, 'TripViz', /*mappings*/, /*filteredBy*/, /*dermatologyProperties*/ );    