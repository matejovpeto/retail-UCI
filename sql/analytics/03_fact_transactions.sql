/** Created fact_transactions table
    Added transaction_id as PK to represent each transaction line separately
    Tables joined to dim_product and dim_customer -> represented by its FK
**/


DROP TABLE IF EXISTS analytics.fact_transactions;

SELECT             ROW_NUMBER() OVER (ORDER BY invoice_number, invoice_datetime, p.product_id, c.customer_dim_id) as transaction_id
                   ,[invoice_number]
                   ,[invoice_type]
                   ,p.product_id
                   ,[quantity]
                   ,[invoice_datetime]
                   ,[unit_price]
                   ,[revenue]
                   ,c.customer_dim_id
INTO analytics.fact_transactions
FROM [retail_UCI].[staging].[retail_data_enriched] e
LEFT JOIN [analytics].[dim_product] p
ON e.stock_code=p.stock_code
AND e.product_type=p.product_type
LEFT JOIN [analytics].[dim_customer] c  
ON e.customer_id=c.customer_id
AND e.customer_country=c.customer_country
