EXPORT A_Data_Ingestion := MODULE

EXPORT Layout := RECORD
  INTEGER    id;
  UNSIGNED4 trade_date;
  DECIMAL9_2 opening_price;
  DECIMAL9_2 low_price;
  DECIMAL9_2 closing_price;
  DECIMAL9_2 high_price;
  UNSIGNED4 shares_traded;
END;

EXPORT raw := DATASET('~stockdata', Layout, THOR);

END;
