/** Created dim_product from enriched staging data
    Initially there was a deduplication needed to be done as there were cases where the same stock_code had multiple
    naming variations in product_description (referring to the same product) -> done using count and window function
    There was a separate PK column created -> product_id
    Added revenue classification for the upcoming revenue calculations
**/

 DROP TABLE IF EXISTS analytics.dim_product;
 
 WITH cte_cnt AS (
        SELECT      [stock_code]
                   ,[product_type]
                   ,[product_description]
                   ,COUNT(*) as cnt
        FROM [retail_UCI].[staging].[retail_data_enriched]
        GROUP BY    stock_code
                   ,product_type
                   ,product_description
                 ),
      cte_rn AS (
SELECT              *
                   ,ROW_NUMBER() OVER (PARTITION BY stock_code ORDER BY cnt desc, product_description) as rn
FROM cte_cnt
                )

SELECT          ROW_NUMBER() OVER (ORDER BY stock_code) as product_id 
               ,stock_code
               ,product_type
               ,product_description
               ,(CASE WHEN product_type IN (
                                               'Shipping'
                                               ,'Voucher'
                                               ,'Discount'
                                               ,'Adjustment'
                                               ) THEN 'Gross'
                           WHEN product_type IN (
                                                'Bank Charges'
                                                ,'Fee'
                                                ,'Samples'
                                                ,'Bad debt'
                                                ) THEN 'Non-Revenue'
                           WHEN product_type = 'Product' THEN 'Gross/Net'
                           END) as revenue_class
INTO analytics.dim_product
FROM cte_rn
WHERE rn = 1