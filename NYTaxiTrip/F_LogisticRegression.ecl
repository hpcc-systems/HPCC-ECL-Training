IMPORT ML_Core;
IMPORT ML_Core.Types;
IMPORT NYTaxiTrip.D_Data_Enhancement;
IMPORT LogisticRegression AS LR;

//Reading enhanced data
enhancedData := D_Data_Enhancement.enhancedData;


//Average trips per day
avgTrip := AVE(enhancedData, trip_counts);

//Add trend layout
trainLayout := RECORD
  INTEGER id;
  INTEGER month_of_year;
  INTEGER day_of_week;
  REAL8   precipintensity;
  INTEGER trend;
END;

trainData := PROJECT(enhancedData, TRANSFORM(trainLayout,
                                            SELF.trend := IF(LEFT.trip_counts < avgTrip, 0, 1),
                                            SELF := LEFT));

//Transform to Machine Learning Dataframe, such as NumericField
ML_Core.ToField(trainData, NFtrain);

// split into input (X) and output (Y) variables
X := NFtrain(number < 4);
Y := PROJECT(NFtrain(number = 4), TRANSFORM(Types.DiscreteField, SELF.number := 1, SELF := LEFT));

//Training LogisticRegression Model
mod_bi := LR.BinomialLogisticRegression(100,0.00001).getModel(X, Y);

//Prediction
predict_bi := LR.BinomialLogisticRegression().Classify(mod_bi, X);
OUTPUT(predict_bi);