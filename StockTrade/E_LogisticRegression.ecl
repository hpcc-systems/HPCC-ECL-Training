IMPORT ML_Core;
IMPORT ML_Core.Types as Types;
IMPORT LogisticRegression AS LR;
IMPORT StockTrade.D_Data_Enhancement;

/**
  * Train and test Logistic Regression model on Apple's stock data
  */

// Read enhanced data
stocks := D_Data_Enhancement.enhancedData;

//Transform to Machine Learning Dataframe, such as NumericField
ML_Core.ToField(stocks, train);

// split into input (X) and output (Y) variables
X := train(number < 8);
Y := PROJECT(train(number = 8), TRANSFORM(Types.DiscreteField, SELF.number := 1, SELF := LEFT));

//Training LogisticRegression Model
mod_bi := LR.BinomialLogisticRegression(100,0.00000001).getModel(X, Y);

//Prediction
predict_bi := LR.BinomialLogisticRegression().Classify(mod_bi, X);
OUTPUT(predict_bi);
