IMPORT ML_Core;
IMPORT ML_Core.Types;
IMPORT LogisticRegression AS LR;

#WORKUNIT('NAME', '4_LogisticRegression');

//Reading data
Layout := RECORD
    INTEGER id;
    REAL8   precipitation;
    INTEGER trend; //Define the Classes: 0 --> decrease, 1 --> increase

END;
raw := DATASET('~trainset', Layout, CSV(HEADING(1)));

//Transform to Machine Learning Dataframe, such as NumericField
ML_Core.ToField(raw, NFtrain);

//Independent and Dependent data
DStrainInd := NFtrain(number = 1);
DStrainDpt := PROJECT(NFtrain(number = 2), TRANSFORM(Types.DiscreteField, SELF.number := 1, SELF := LEFT));

//Training LogisticRegression Model
mod_bi := LR.BinomialLogisticRegression(100,0.00001).getModel(DStrainInd(id <= 50), DStrainDpt(id <= 50));

//Prediction
predict_bi := LR.BinomialLogisticRegression().Classify(mod_bi, DStrainInd(id > 50));
OUTPUT(predict_bi);