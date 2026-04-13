/** Created dim_customer
    customer_dim_id created as PK to deal with the "Unknown" customer_id issue (23% of customer_id unidentified)
    Added customer_continent + customer_subregion for better geographic analysis
**/


DROP TABLE IF EXISTS analytics.dim_customer;

WITH country_classification AS (
    SELECT *
    FROM (VALUES
        -- Northern Europe
        ('Finland', 'Europe', 'Northern Europe'),
        ('EIRE', 'Europe', 'Northern Europe'),
        ('Iceland', 'Europe', 'Northern Europe'),
        ('United Kingdom', 'Europe', 'Northern Europe'),
        ('Sweden', 'Europe', 'Northern Europe'),
        ('Denmark', 'Europe', 'Northern Europe'),
        ('Norway', 'Europe', 'Northern Europe'),
        ('Channel Islands', 'Europe', 'Northern Europe'),

        -- Western Europe
        ('Netherlands', 'Europe', 'Western Europe'),
        ('Germany', 'Europe', 'Western Europe'),
        ('Austria', 'Europe', 'Western Europe'),
        ('France', 'Europe', 'Western Europe'),
        ('Belgium', 'Europe', 'Western Europe'),
        ('Switzerland','Europe','Western Europe'),

        -- Southern Europe
        ('Italy', 'Europe', 'Southern Europe'),
        ('Cyprus', 'Europe', 'Southern Europe'),
        ('Malta', 'Europe', 'Southern Europe'),
        ('Greece', 'Europe', 'Southern Europe'),
        ('Spain', 'Europe', 'Southern Europe'),
        ('Portugal', 'Europe', 'Southern Europe'),

        -- Eastern Europe
        ('Lithuania', 'Europe', 'Eastern Europe'),
        ('Poland', 'Europe', 'Eastern Europe'),
        ('Czech Republic', 'Europe', 'Eastern Europe'),

        -- Europe - supranational
        ('European Community', 'Europe', 'European Community'),

        -- North America
        ('USA', 'North America', 'Northern America'),
        ('Canada', 'North America', 'Northern America'),
        ('Bermuda', 'North America', 'Caribbean'),

        -- South America
        ('Brazil', 'South America', 'South America'),

        -- Eastern Asia
        ('Hong Kong', 'Asia', 'Eastern Asia'),
        ('Korea', 'Asia', 'Eastern Asia'),
        ('Japan', 'Asia', 'Eastern Asia'),

        -- Western Asia / Middle East
        ('Bahrain', 'Asia', 'Middle East'),
        ('Lebanon', 'Asia', 'Middle East'),
        ('Saudi Arabia', 'Asia', 'Middle East'),
        ('United Arab Emirates', 'Asia', 'Middle East'),
        ('Israel', 'Asia', 'Middle East'),

        -- Southeast Asia
        ('Thailand', 'Asia', 'Southeast Asia'),
        ('Singapore', 'Asia', 'Southeast Asia'),

        -- Africa
        ('RSA', 'Africa', 'Southern Africa'),
        ('Nigeria', 'Africa', 'Western Africa'),

        -- Oceania
        ('Australia', 'Oceania', 'Australia and New Zealand'),

        -- Other / unclear
        ('West Indies', 'North America', 'Caribbean'),
        ('Unspecified', 'Other', 'Unspecified')
    ) AS t(customer_country,customer_continent,customer_subregion)
),
    cte_unique AS (
SELECT DISTINCT  t.customer_id
                ,t.customer_country
                ,cc.customer_continent
                ,cc.customer_subregion

FROM [staging].[retail_data_enriched] t
LEFT JOIN country_classification cc
    ON t.customer_country = cc.customer_country
)

SELECT           ROW_NUMBER() OVER (ORDER BY customer_id) as customer_dim_id
                ,*
INTO analytics.dim_customer
FROM cte_unique