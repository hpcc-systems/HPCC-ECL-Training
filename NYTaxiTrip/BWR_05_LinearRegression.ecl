IMPORT STD;
IMPORT ML_Core;
IMPORT ML_Core.Types;
IMPORT LinearRegression AS LROLS;

#WORKUNIT('NAME', '5_LinearRegression');

//Reading Taxi_Weather Data
Layout := RECORD
  STD.Date.Date_t date;
  REAL8 precipintensity;
  INTEGER trip_counts;
END;
raw := DATASET('~thor::taxi::traindata', Layout, THOR);

//Enhance raw data
enhancedLayout := RECORD
  INTEGER id;
  INTEGER month_of_year;
  INTEGER day_of_week;
  REAL8   precipintensity;
  INTEGER trip_counts;
END;

enhancedData := PROJECT(raw, TRANSFORM(enhancedLayout,
                                        SELF.id := COUNTER,
                                        SELF.day_of_week := (INTEGER) Std.Date.DayOfWeek(LEFT.date),
                                        SELF.month_of_year := (INTEGER) LEFT.date[5..6],
                                        SELF.precipintensity := LEFT.precipintensity,
                                        SELF.trip_counts := LEFT.trip_counts));

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
