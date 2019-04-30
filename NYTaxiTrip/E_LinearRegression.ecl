IMPORT STD;
IMPORT ML_Core;
IMPORT ML_Core.Types;
IMPORT NYTaxiTrip.D_Data_Enhancement;
IMPORT LinearRegression AS LROLS;

//Reading enhanced data
enhancedData := D_Data_Enhancement.enhancedData;

//Transform to Machine Learning Dataframe, such as NumericField
ML_Core.ToField(enhancedData, train);
OUTPUT(train);

//Independent and Dependent data
X := train(number < 4);
Y := train(number = 4);


//Training LinearRegression Model
lr := LROLS.OLS(X, Y);

//Prediction
predict := lr.predict(X);
OUTPUT(predict);
