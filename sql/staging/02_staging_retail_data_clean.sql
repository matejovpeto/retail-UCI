/** Deleting approx. 0,6% values from the dataset where unit_price = 0 
    Those items do not generate any revenue, they do not possess any relevant info regarding product or customer
    Some of those products are marked as damaged/missing/broken/lost,... but with no additional info that we could use for
    calculations as e.g. the value of stocks damaged, missing, whatsoever **/

DELETE FROM [staging].[retail_data] 
    WHERE unit_price = 0;

/** Deleting also 17 rows of test products which we can presume to be not for sale, almost 0 impact **/

DELETE FROM [staging].[retail_data] 
    WHERE stock_code LIKE 'TEST%';
