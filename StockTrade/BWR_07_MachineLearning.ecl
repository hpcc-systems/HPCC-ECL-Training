IMPORT StockTrade.Util;
IMPORT ML_Core;
#WORKUNIT('name', 'Stock Data: Logistic Regression');
/**
  * Train and test Logistic Regression model on Apple's stock data
  */

// Load APPLE stock data from year of 2005 to year of 2006.
stocks := Util.LoadData('O','AAPL',2005, 2006);

// split into input (X) and output (Y) variables
X := stocks(number < 8);
Y := stocks(number = 8);

// train model
model := Util.LogisticRegression(30, 0.001).fit(X, Y);

// calculate predictons
predictions := Util.predict(model, X);
OUTPUT(predictions);
