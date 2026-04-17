# 📊 Online Retail II – Data Analysis Project



## 📌 Overview

This project analyzes a messy transactional dataset containing all transactions for a UK-based e-commerce business between **01/12/2009** and **09/12/2011**.



The goal of the project was to:

- explore and understand the dataset

- clean and transform the data into a usable format

- design a data model

- build a Power BI report with business-relevant KPIs



The project covers:

- data transformation in SQL

- data modelling (star schema)

- visualisations in Power BI

- KPI definition and calculation



---



## 🛠️ Tech Stack

- SQL Server

- Power BI

- DAX



---



## 🗂️ Data Model

A **star schema** was used for this project.



### Fact Table

#### `fact_transactions`

- Grain: **1 row = 1 transaction line per invoice and product**

- Contains:

&#x20; - `invoice_number`

&#x20; - `invoice_type`

&#x20; - `quantity`

&#x20; - `invoice_datetime`

&#x20; - `unit_price`

&#x20; - `revenue`

&#x20; - `product_id` (FK)

&#x20; - `customer_dim_id` (FK)



### Dimension Tables



#### `dim_calendar`

- Created in Power BI

- Used for time intelligence (YTD, PY YTD, YoY, monthly trends)



#### `dim_customer`

- `customer_id`

- `customer_country`

- `customer_continent`

- `customer_subregion`

- `customer_dim_id`



> ⚠️ **Note**  

> More than **20% of `customer_id` values are missing** in the source data.  

> These rows were preserved because they still represent valid business transactions.  

> Missing customers are represented as **Unknown** and grouped by geography.  

>

> As a result:

> - customer counts are **indicative rather than exact**

> - one real unidentified customer cannot be tracked uniquely

> - multiple unknown customers may exist within the same country



#### `dim_product`

- `product_id`

- `stock_code`

- `product_type`

- `product_description`

- `revenue_class`



> **Note**  

> Some `stock_code` values appeared under multiple naming variations in `product_description`.  

> To keep one product row per `stock_code`, the most frequent description was selected using a frequency-based deduplication approach.



---



## 🧹 Data Challenges and SQL Approach



The dataset required substantial cleaning and interpretation before it could be analysed reliably.



### 1. Inconsistent Transaction Types

The dataset contains multiple types of transactions mixed together:

- normal invoices

- credit memos / returns / cancellations

- bad debt adjustments

- shipping charges

- vouchers / discounts

- fees and bank charges

- samples



### Approach

Two classification layers were created:



#### `invoice_type`

Based on `invoice_number`:

- `Invoice`

- `Credit Memo`

- `Bad debt`



#### `product_type`

Based on `stock_code`:

- `Product`

- `Shipping`

- `Voucher`

- `Discount`

- `Adjustment`

- `Bank Charges`

- `Fee`

- `Samples`

- `Bad debt`



This made it possible to interpret the dataset more like a real business transaction model instead of a flat raw export.



---



### 2. Revenue Definition

Revenue was not directly available as a reliable business metric.



### Approach

Revenue was defined as `quantity * unit_price`.



Additional logic was needed:

- **Credit memos** remained negative through quantity

- **Vouchers** were sign-adjusted to reduce shipping-related revenue

- **Bad debt** was classified as **Non-Revenue**

- **Fees, bank charges, and samples** were kept in the model, but separated from product-relevant revenue



---



### 3. Revenue Classification

A separate `revenue_class` was introduced to distinguish different revenue buckets:



- `Gross`

- `Gross/Net`

- `Non-Revenue`



### Logic

- **Gross/Net** → regular product sales

- **Gross** → products, shipping, vouchers, discounts, adjustments

- **Non-Revenue** → fees, bank charges, samples, bad debt



This made it possible to calculate:

- **Product Revenue**

- **Gross Revenue**

- **Non-Revenue Transactions**



---



### 4. Missing and Invalid Data

Several issues were identified in the raw data:

- rows with `unit_price = 0`

- test products (`TEST%`)

- missing product descriptions

- rows with missing customer IDs

- negative rows that required interpretation



### Approach

- removed rows with `unit_price = 0`

- removed obvious test products

- preserved meaningful negative rows such as returns / credit memos

- preserved rows with missing `customer_id` because they still represented valid business transactions



---



### 5. Product Duplication

Some `stock_code` values were linked to multiple naming variations in `product_description`.



### Approach

Instead of deleting transaction rows, product descriptions were deduplicated only in the product dimension:

- grouped by `stock_code`, `product_type`, and `product_description`

- counted occurrences

- selected the most frequent description per `stock_code`



This preserved transaction history while keeping the product dimension clean.



---



### 6. Customer Identity Issues

The source dataset does not allow exact customer tracking for all rows because many `customer_id` values are missing.



### Approach

- missing customer IDs were preserved as `Unknown`

- customer geography was still retained

- a surrogate key `customer_dim_id` was introduced in `dim_customer`



This allowed:

- geographic analysis

- customer segmentation with limitations

- retention of a large volume of valid data that would otherwise be lost



---



## 📊 Power BI Challenges and Approach



### Customer Metrics Limitation

Because `Unknown` customers were preserved, customer metrics are directionally useful but not exact.



### Impact

Metrics such as:

- `Total Customers`

- `Active Customers`

- `Revenue per Customer`



must be interpreted with caution.



### Why they were still kept

Removing all missing-customer rows would have significantly reduced the analytical value of the dataset and hidden a meaningful portion of the business activity.



---



## 📸 Dashboard



### Overview

![Overview](overview.png)



This page focuses on high-level performance:

- Gross Revenue YoY

- Product Revenue YoY

- Total Invoices

- Credit Memo Share

- Gross vs Non-Revenue trend

- monthly product revenue comparison



### Customers and Regions

![Customers and Regions](customers&regions.png)



This page focuses on geographic customer distribution:

- Product Revenue split by continent and subregion

- Total Customers

- Active Customers YoY

- Top countries by Product Revenue



> **Note**  

> Customer-related metrics on this page are affected by the preserved `Unknown` customer logic and should be interpreted as indicative rather than exact.



### Product

![Product](product.png)



This page focuses on product and transaction mix:

- Top Products by Revenue

- Top Products by Quantity

- Product Revenue trend

- Impact of non-product transactions such as shipping, vouchers, fees, bad debt, and adjustments



---



## 📁 Project Structure



&#x20;   sql/

&#x20;   ├── raw/

&#x20;   │   └── 01_raw_to_staging.sql

&#x20;   ├── staging/

&#x20;   │   ├── 01_data_profiling.sql

&#x20;   │   ├── 02_staging_retail_data_clean.sql

&#x20;   │   └── 03_staging_retail_data_enrich.sql

&#x20;   └── analytics/

&#x20;       ├── 01_dim_product.sql

&#x20;       ├── 02_dim_customer.sql

&#x20;       └── 03_fact_transactions.sql



---



## ✅ Project Outcome

The final result of the project is:

- a cleaned and modelled SQL backend

- a star schema for reporting

- a multi-page Power BI report

- KPI calculations reflecting both product revenue and non-product transaction impacts



