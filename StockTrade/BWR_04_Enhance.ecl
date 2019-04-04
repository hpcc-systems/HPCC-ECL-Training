IMPORT StockTrade;
IMPORT Std;

#WORKUNIT('name', 'Stock Data: Enhance Cleaned Data');

baseData := StockTrade.Files.Cleaned.ds;

// Append a 'symbol' field that contains the stock exchange code and stock
// symbol code in <exchange>:<symbol> format; also extract and append
// information from the trade date to expose more features for analytics
enhancedData1 := PROJECT
    (
        baseData,
        TRANSFORM
            (
                StockTrade.Files.Enhanced.Layout,
                SELF.symbol := StockTrade.Util.MakeFullSymbol(LEFT.exchange_code, LEFT.stock_symbol),
                SELF.trade_year := Std.Date.Year(LEFT.trade_date),
                SELF.trade_month := Std.Date.Month(LEFT.trade_date),
                SELF.trade_day := Std.Date.Day(LEFT.trade_date),
                SELF.trade_day_of_week := Std.Date.DayOfWeek(LEFT.trade_date),
                SELF.trade_quarter := (SELF.trade_month DIV 4) + 1,
                SELF.trade_day_of_year := Std.Date.DayOfYear(LEFT.trade_date),
                SELF.trade_day_of_quarter := Std.Date.DaysBetween
                    (
                        Std.Date.DateFromParts(SELF.trade_year, (SELF.trade_quarter - 1) * 3 + 1, 1),
                        LEFT.trade_date
                    ) + 1,
                SELF := LEFT,
                SELF := []
            )
    );

// Explicitly distribute the data based on the full <exchange>:<symbol> value;
// all records with the same full value will wind up on the same Thor node
distDS := DISTRIBUTE(enhancedData1, HASH32(symbol));

// Group all records around their full symbol, sorted by trade date; note that
// both the SORT and GROUP operation can be LOCAL because we explicitly
// distributed the data that way
groupedData := GROUP(SORT(distDS, symbol, trade_date, LOCAL), symbol, LOCAL);

// Within each group, iterate through the records and compute changes between
// one record and the next; within the transform, LEFT is the previous record
// created and RIGHT is the next record from the dataset
withChanges := ITERATE
    (
        groupedData,
        TRANSFORM
            (
                RECORDOF(LEFT),
                SELF.opening_price_change := IF(LEFT.symbol != '', RIGHT.opening_price - LEFT.opening_price, 0),
                SELF.closing_price_change := IF(LEFT.symbol != '', RIGHT.closing_price - LEFT.closing_price, 0),
                SELF.shares_traded_change := IF(LEFT.symbol != '', RIGHT.shares_traded - LEFT.shares_traded, 0),
                SELF := RIGHT
            )
    );

// Add a unique ID value to each record within a symbol group; this ID will
// be used to find trade date records within a certain number of business days
// within each other (dates are less reliable due to weekends, holidays, etc)
withID := PROJECT
    (
        withChanges,
        TRANSFORM
            (
                {
                    INTEGER4    id,
                    RECORDOF(LEFT)
                },
                SELF.id := COUNTER,
                SELF := LEFT
            )
    );

// Ungroup the data, so subsequent operations operate on the entire dataset
// rather than each group individually
ungroupedData := UNGROUP(withID);

// Perform a self-join where LEFT is one record and ROWS(RIGHT) is the
// collection of records with the same symbol and within
// StockTrade.Util.Constants.MOVING_AVE_DAYS days in the past
withMovingAve := DENORMALIZE
    (
        ungroupedData,
        ungroupedData,
        LEFT.symbol = RIGHT.symbol
            AND RIGHT.id > 0
            AND RIGHT.id BETWEEN (LEFT.id - StockTrade.Util.Constants.MOVING_AVE_DAYS) AND (LEFT.id - 1),
        GROUP,
        TRANSFORM
            (
                RECORDOF(LEFT),
                SELF.moving_ave_opening_price := IF(COUNT(ROWS(RIGHT)) = StockTrade.Util.Constants.MOVING_AVE_DAYS, AVE(ROWS(RIGHT), opening_price), 0),
                SELF.moving_ave_high_price := IF(COUNT(ROWS(RIGHT)) = StockTrade.Util.Constants.MOVING_AVE_DAYS, AVE(ROWS(RIGHT), high_price), 0),
                SELF.moving_ave_low_price := IF(COUNT(ROWS(RIGHT)) = StockTrade.Util.Constants.MOVING_AVE_DAYS, AVE(ROWS(RIGHT), low_price), 0),
                SELF.moving_ave_closing_price := IF(COUNT(ROWS(RIGHT)) = StockTrade.Util.Constants.MOVING_AVE_DAYS, AVE(ROWS(RIGHT), closing_price), 0),
                SELF := LEFT
            ),
        LOCAL
    );

// Remove the ID value we added in order to calculate the moving averages
withoutID := PROJECT
    (
        withMovingAve,
        TRANSFORM
            (
                RECORDOF(LEFT) - [id],
                SELF := LEFT
            )
    );

// Write the result as a native Thor logical file
OUTPUT(withoutID, /*RecStruct*/, StockTrade.Files.Enhanced.PATH, OVERWRITE, COMPRESSED);
