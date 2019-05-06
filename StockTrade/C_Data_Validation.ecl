IMPORT StockTrade.A_Data_Ingestion;

EXPORT C_Data_Validation := MODULE
//Reading Taxi_Weather Data
SHARED raw := A_Data_Ingestion.raw;

//Data Validation
EXPORT validSet := raw( shares_traded <> 0 AND low_price <> 0 );
END;