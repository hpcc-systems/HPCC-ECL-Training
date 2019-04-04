IMPORT NYTaxiTrip.Data_Modules;
IMPORT Data_Modules.Taxi_Weather;
IMPORT ML_Core.Analysis;
IMPORT NYTaxiTrip.Utils;


#WORKUNIT('NAME', '5_LogisticRegression');

//Load Taxi data
taxi_weather_engineered := Taxi_Weather.ds.engineered;

//Train model
logistic_model := Utils.logisticModel(100 , 0.001);
model := logistic_model.fit(taxi_weather_engineered);

//Calculate predictons
logistic_predict := logistic_model.predict(model, taxi_weather_engineered);
OUTPUT(logistic_predict);