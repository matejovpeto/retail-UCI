-- INVOICE PATTERNS

-- 19,5k invoices starting with C -> most likely Credit Memos/cancellations
-- It will be analyzed separately from the normal invoices

SELECT         [invoice_number]
              ,[stock_code]
              ,[product_description]
              ,[quantity]
              ,[invoice_datetime]
              ,[unit_price]
              ,[customer_id]
              ,[customer_country]
FROM [staging].[retail_data]
WHERE invoice_number LIKE 'C%'

-- 6 invoices starting with A -> bad debt adjustment
-- approx. value of 150k

SELECT         [invoice_number]
              ,[stock_code]
              ,[product_description]
              ,[quantity]
              ,[invoice_datetime]
              ,[unit_price]
              ,[customer_id]
              ,[customer_country]
FROM [staging].[retail_data]
WHERE invoice_number LIKE 'A%'

-- 3,5k cases that are normal invoices, with negative quantities, all of them 0 price, no customer_id
-- likely non-standard or invalid transactions 

SELECT [invoice_number]
      ,[stock_code]
      ,[product_description]
      ,[quantity]
      ,[invoice_datetime]
      ,[unit_price]
      ,[customer_id]
      ,[customer_country]
FROM [staging].[retail_data]
WHERE quantity < 0
AND invoice_number NOT LIKE '%[a-z]%'

-- STOCK_CODE TYPES

-- 135k stock codes with letter in the naming
-- 5,1k unique stock codes out of them 1,5k with letters in the code
-- POST - postage
-- DOT - dotcom postage
-- ADJUST - adjustments
-- AMAZONFEE - amazon fee
-- CRUK - CRUK Commission
-- gift - vouchers
-- PADS - ??
-- TEST - test products
-- stock codes with letters in the naming might also refer to specific product group or product color

SELECT DISTINCT    [stock_code]
                  ,[product_description]
FROM [staging].[retail_data]
WHERE stock_code LIKE '%[a-z][a-z][a-z]%'

-- within Credit memos, its e.g. D - discount, S - samples, M - manual, C2 - Carriage,...
-- the stock_codes will require further classification

SELECT DISTINCT    [invoice_number]
                  ,[stock_code]
                  ,[product_description]
FROM [staging].[retail_data]
WHERE stock_code LIKE '%[a-z]%'
AND invoice_number LIKE '%[a-z]%'
ORDER BY stock_code desc

-- PRODUCT_DESCRIPTION

-- product description
-- 4,4k null values, all of them 0 unit price and null customer_id

SELECT *
FROM [staging].[retail_data]
WHERE product_description IS NULL

-- CUSTOMER_ID

-- customer_id - 243k null values

SELECT *
FROM [staging].[retail_data]
WHERE customer_id IS NULL
