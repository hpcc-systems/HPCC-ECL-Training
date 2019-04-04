IMPORT Std;
IMPORT ML_Core;
IMPORT ML_Core.Types AS Types;
IMPORT StockTrade;
IMPORT LogisticRegression AS LR;

EXPORT Util := MODULE

    EXPORT Constants := MODULE

        EXPORT MOVING_AVE_DAYS := 5;
        EXPORT TRADE_START_DATE := 20030101;
        EXPORT TRADE_END_DATE := 20181101;
        EXPORT TRADE_START_YEAR := STD.Date.Year(TRADE_START_DATE);
        EXPORT TRADE_END_YEAR := STD.Date.Year(TRADE_END_DATE);
    END;

    EXPORT DescribeExchangeCode(STRING1 exchCode) := CASE
        (
            Std.Str.ToUpperCase(exchCode),
            'O' =>  'NASDAQ',
            'N' =>  'NYSE',
            'A' =>  'AMEX',
            ERROR('Unknown exchange code: "' + exchCode + '"')
        );

    EXPORT MakeFullSymbol(STRING1 exchCode, STRING9 symbol) := TRIM(DescribeExchangeCode(exchCode)) + ':' + symbol;

    //Scaler
    EXPORT Scaler(DATASET(Types.NumericField) ds) := FUNCTION
        scale:= ML_Core.FieldAggregates(ds).simple;
        rst := JOIN
            (
                ds,
                scale,
                LEFT.wi = RIGHT.wi
                    AND LEFT.number = RIGHT.number,
                TRANSFORM
                    (
                        Types.NumericField,
                        SELF.value := (LEFT.value - RIGHT.minval) / (RIGHT.maxval- RIGHT.minval),
                        SELF := LEFT
                    ),
                LOOKUP
            );

        RETURN rst;
    END;

    // Return Stock Data based on the exchange code, ticket symbol and provided year
    EXPORT LoadData(STRING4 code = 'O',
                         STRING4 ticket = 'AAPL',
                         UNSIGNED4 start_year = Constants.TRADE_START_YEAR,
                         UNSIGNED4 end_year = Constants.TRADE_END_YEAR) := FUNCTION

        fullSymbol := MakeFullSymbol(code, ticket);
        baseData :=  StockTrade.Files.Features.ds(
                                                stock_symbol = 'AAPL' AND
                                                (direction = 0 OR direction = 1) AND
                                                STD.Date.Year(trade_date) >= start_year AND
                                                STD.Date.Year(trade_date) <= end_year);
        ds := PROJECT
            (
                baseData,
                TRANSFORM
                    (
                        StockTrade.Files.Preprocessing.Layout,
                        SELF.id := COUNTER,
                        SELF := LEFT
                    )
            );
        ML_Core.ToField(ds, trainset);
        RETURN trainset;
    END;
    EXPORT LogisticRegression(UNSIGNED max_iter=200,
                                        REAL8 epsilon=0.0001):= MODULE
        EXPORT Fit(DATASET(ML_Core.Types.NumericField) ind,
                                        DATASET(ML_Core.Types.NumericField) dep) := FUNCTION
            m :=  LR.BinomialLogisticRegression(Max_Iter, epsilon);
            DStrainInd_scaled:= Scaler(ind);
            DStrainDpt := PROJECT(dep, TRANSFORM(Types.DiscreteField, SELF.number := 1, SELF := LEFT));
            result := m.getModel(DStrainInd_scaled, DStrainDpt);
            RETURN result;
        END;
    END;

    EXPORT Predict(DATASET(Types.Layout_Model) m, DATASET(ML_Core.Types.NumericField) ind) := FUNCTION
        DStrainInd_scaled:= Scaler(ind);
        predictions := LR.BinomialLogisticRegression().Classify(m, DStrainInd_scaled);
        result := PROJECT(predictions, TRANSFORM(RECORDOF(predictions)-conf-number, SELF := LEFT));
        RETURN result;
    END;
END;
