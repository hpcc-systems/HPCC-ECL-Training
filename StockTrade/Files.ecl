IMPORT Std;
IMPORT ML_Core.Types;

EXPORT Files := MODULE

    EXPORT PATH_PREFIX := '~stock_data';

    //--------------------------------------------------------------------------

    EXPORT Raw := MODULE

        EXPORT Layout := RECORD
            STRING          trade_date;
            STRING          exchange_code;
            STRING          stock_symbol;
            STRING          opening_price;
            STRING          high_price;
            STRING          low_price;
            STRING          closing_price;
            STRING          shares_traded;
            STRING          share_value;
        END;

        EXPORT PATH := PATH_PREFIX + '::raw_data.txt';

        EXPORT ds := DATASET
            (
                PATH,
                Layout,
                CSV(SEPARATOR('\t'), HEADING(1), QUOTE(''))
            );

    END; // Raw module

    //--------------------------------------------------------------------------

    EXPORT Cleaned := MODULE

        EXPORT Layout := RECORD
            Std.Date.Date_t trade_date;
            STRING1         exchange_code;
            STRING9         stock_symbol;
            DECIMAL9_2      opening_price;
            DECIMAL9_2      high_price;
            DECIMAL9_2      low_price;
            DECIMAL9_2      closing_price;
            UNSIGNED4       shares_traded;
            UNSIGNED4       share_value;
        END;

        EXPORT PATH := PATH_PREFIX + '::cleaned_data';

        EXPORT ds := DATASET(PATH, Layout, FLAT);

    END; // Cleaned module

    //--------------------------------------------------------------------------

    EXPORT Profiled := MODULE

        ModeRec := RECORD
            STRING                      value;
            UNSIGNED4                   rec_count;
        END;

        PatternCountRec := RECORD
            STRING                      data_pattern;
            UNSIGNED4                   rec_count;
            STRING                      example;
        END;

        CorrelationRec := RECORD
            STRING                      attribute;
            DECIMAL7_6                  corr;
        END;

        EXPORT Layout := RECORD
            STRING                      attribute;
            STRING                      given_attribute_type;
            STRING                      best_attribute_type;
            UNSIGNED4                   rec_count;
            UNSIGNED4                   fill_count;
            DECIMAL9_6                  fill_rate;
            UNSIGNED4                   cardinality;
            DATASET(ModeRec)            modes{MAXCOUNT(5)};
            UNSIGNED4                   min_length;
            UNSIGNED4                   max_length;
            UNSIGNED4                   ave_length;
            DATASET(PatternCountRec)    popular_patterns{MAXCOUNT(100)};
            DATASET(PatternCountRec)    rare_patterns{MAXCOUNT(100)};
            BOOLEAN                     is_numeric;
            DECIMAL32_4                 numeric_min;
            DECIMAL32_4                 numeric_max;
            DECIMAL32_4                 numeric_mean;
            DECIMAL32_4                 numeric_std_dev;
            DECIMAL32_4                 numeric_lower_quartile;
            DECIMAL32_4                 numeric_median;
            DECIMAL32_4                 numeric_upper_quartile;
            DATASET(CorrelationRec)     numeric_correlations;
        END;

        EXPORT PATH := PATH_PREFIX + '::cleaned_profile';

        EXPORT ds := DATASET(PATH, Layout, FLAT);

    END; // Profiled module

    //--------------------------------------------------------------------------

    EXPORT Enhanced := MODULE

        EXPORT Layout := RECORD
            Cleaned.Layout;
            STRING16        symbol;                     // Exchange name + stock symbol
            UNSIGNED2       trade_year;                 // Year portion of trade_date
            UNSIGNED1       trade_month;                // Month portion of trade_date
            UNSIGNED1       trade_day;                  // Day portion of trade_date
            UNSIGNED1       trade_day_of_week;          // Range 1-7, Sunday = 1
            UNSIGNED1       trade_quarter;              // Calendar quarter; range 1-4
            UNSIGNED1       trade_day_of_year;          // Range 1-366
            UNSIGNED1       trade_day_of_quarter;       // Range 1-92
            DECIMAL9_2      opening_price_change;       // Change in price as compared to previous day
            DECIMAL9_2      closing_price_change;       // Change in price as compared to previous day
            INTEGER4        shares_traded_change;       // Change in volume as compared to previous day
            DECIMAL9_2      moving_ave_opening_price;   // Average of previous StockTrade.Util.Constants.MOVING_AVE_DAYS days opening price
            DECIMAL9_2      moving_ave_high_price;      // Average of previous StockTrade.Util.Constants.MOVING_AVE_DAYS days high price
            DECIMAL9_2      moving_ave_low_price;       // Average of previous StockTrade.Util.Constants.MOVING_AVE_DAYS days low price
            DECIMAL9_2      moving_ave_closing_price;   // Average of previous StockTrade.Util.Constants.MOVING_AVE_DAYS days closing price
        END;

        EXPORT PATH := PATH_PREFIX + '::enhanced_data';

        EXPORT ds := DATASET(PATH, Layout, FLAT);

    END; // Enhanced module

    //--------------------------------------------------------------------------

    EXPORT Summarized := MODULE

        EXPORT Layout := RECORD
            STRING16            symbol;
            Std.Date.Date_t     first_seen_date;
            Std.Date.Date_t     last_seen_date;
            UNSIGNED4           num_trading_days;
            DECIMAL9_2          lowest_closing_price;
            DECIMAL9_2          highest_closing_price;
        END;

        EXPORT PATH := PATH_PREFIX + '::symbol_summary';

        EXPORT ds := DATASET(PATH, Layout, FLAT);

    END; // Summarized module

    //--------------------------------------------------------------------------

    EXPORT Features := MODULE

        EXPORT Layout := RECORD
            Enhanced.Layout;
            Types.t_RecordID   id;                        // Append ID to each instance
            REAL4              shares_traded_change_rate; // Volume Change rate in volume as compared to previous day
            UNSIGNED4          direction;                 // 0->down; 1->up; 2->even
        END;

        EXPORT PATH := PATH_PREFIX + '::full_data';

        EXPORT ds := DATASET(PATH, Layout, FLAT);

    END; // Features module

    //--------------------------------------------------------------------------

    EXPORT Preprocessing := MODULE

        EXPORT Layout := RECORD
            Features.Layout.id;
            Enhanced.Layout.opening_price_change;
            Enhanced.Layout.closing_price_change;
            Enhanced.Layout.moving_ave_opening_price;
            Enhanced.Layout.moving_ave_high_price;
            Enhanced.Layout.moving_ave_low_price;
            Enhanced.Layout.moving_ave_closing_price;
            Features.Layout.shares_traded_change_rate;
            Features.Layout.direction;
        END;

        EXPORT PATH := PATH_PREFIX + '::working_Data';
        EXPORT ds := DATASET(PATH, Layout, FLAT);

    END; // Preprocessing module

END;
