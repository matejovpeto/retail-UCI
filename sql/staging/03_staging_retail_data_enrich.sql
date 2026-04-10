/** Adding Invoice_type classification based on invoice_number
    Adding product_type classification based on stock_code
    Adding revenue column
    Sign-adjusted revenue calculation for product_type = 'Voucher' -> assumption -> they are supposed to lower shipping charges **/

DROP TABLE IF EXISTS staging.retail_data_enriched;

WITH cte_grouping as (
SELECT [invoice_number]
      ,(CASE WHEN invoice_number LIKE 'C%' THEN 'Credit Memo'
             WHEN invoice_number LIKE 'A%' THEN 'Bad debt'
             ELSE 'Invoice'
             END
        ) as invoice_type
      ,[stock_code]
      ,(CASE WHEN stock_code IN ('M','ADJUST','ADJUST2') THEN 'Adjustment'
             WHEN stock_code = 'B' THEN 'Bad debt'
             WHEN stock_code = 'D' THEN 'Discount'
             WHEN stock_code = 'S' THEN 'Samples'
             WHEN stock_code IN ('AMAZONFEE','CRUK') THEN 'Fee'
             WHEN stock_code = 'BANK CHARGES' THEN 'Bank Charges'
             WHEN stock_code IN ('DOT','POST') OR stock_code IN ('C2','C3') THEN 'Shipping'
             WHEN stock_code LIKE 'gift%' THEN 'Voucher'
             ELSE 'Product'
             END) as product_type
      ,[product_description]
      ,[quantity]
      ,[invoice_datetime]
      ,[unit_price]
      ,COALESCE([customer_id],'Unknown') as customer_id
      ,[customer_country]
FROM [staging].[retail_data])

SELECT       invoice_number
            ,invoice_type
            ,stock_code
            ,product_type
            ,product_description
            ,[quantity]
            ,[invoice_datetime]
            ,[unit_price]
            ,(CASE WHEN product_type = 'Voucher' THEN (quantity * unit_price) * -1
                   ELSE (quantity * unit_price)
                   END) as revenue
            ,customer_id
            ,customer_country
INTO staging.retail_data_enriched
FROM cte_grouping


            