-- Initial transformation from raw dataset
-- datatypes changes to match reality
-- column name changes 

DROP TABLE IF EXISTS staging.retail_data;

SELECT
                   CAST([Invoice] as varchar(20)) as invoice_number
                  ,CAST([StockCode] as varchar(20)) as stock_code
                  ,CAST([Description] as nvarchar(100)) as product_description
                  ,CAST([Quantity] as int) as quantity
                  ,CAST([InvoiceDate] as datetime) as invoice_datetime
                  ,CAST([Price] as decimal(10,2)) as unit_price
                  ,CAST(ROUND([Customer_ID],0) as nvarchar(20)) as customer_id
                  ,CAST([Country] as nvarchar(50)) as customer_country
INTO staging.retail_data
FROM [retail_UCI].[raw].[online_retail_II]
