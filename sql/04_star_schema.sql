-- FACT_SALES
CREATE OR ALTER VIEW fact_sales AS
SELECT  date,
        sku,
        channel,
        region,
        pack_type,
        promotion_flag AS promotion_flag,
        price_unit,
        units_sold AS units_sold,
        delivered_qty,
        stock_available AS stock_available,
        ROUND(price_unit * units_sold, 2) AS revenue_proxy,
        CASE WHEN stock_available = 0 THEN 1 ELSE 0 END AS is_stockout
FROM fmcg_sales
WHERE units_sold >= 0
  AND delivered_qty >= 0
  AND stock_available >= 0

GO

-- DIM_PRODUCT
CREATE OR ALTER VIEW dim_product AS
SELECT  sku,
        MAX(brand) AS brand,
        MAX(segment) AS segment,
        MAX(category) AS category
FROM fmcg_sales
GROUP BY sku

GO

-- DIM_CHANNEL
CREATE OR ALTER VIEW dim_channel AS
SELECT DISTINCT channel
FROM fmcg_sales

GO

-- DIM_REGION
CREATE OR ALTER VIEW dbo.dim_region AS
SELECT DISTINCT region
FROM fmcg_sales

GO

-- DIM_DATE
IF OBJECT_ID('dim_date', 'U') IS NOT NULL DROP TABLE dim_date;
CREATE TABLE dim_date
(date DATE PRIMARY KEY,
 year INT,
 quarter INT,
 month INT,
 month_name NVARCHAR(50),
 iso_week INT,
 dow INT,
 is_weekend BIT
);
WITH DateSeries AS
(SELECT CAST('2022-01-01' AS DATE) AS date
 UNION ALL
 SELECT DATEADD(DAY, 1, date)
 FROM DateSeries
 WHERE date < '2025-03-31'
)
INSERT INTO dim_date
(date,
 year,
 quarter,
 month,
 month_name,
 iso_week,
 dow,
 is_weekend
)
SELECT  date,
        YEAR(date),
        DATEPART(QUARTER, date),
        MONTH(date),
        DATENAME(MONTH, date),
        DATEPART(ISO_WEEK, date),
        DATEPART(WEEKDAY, date),
        CASE WHEN DATEPART(WEEKDAY, date) IN (1,7) THEN 1 ELSE 0 END
FROM DateSeries
OPTION (MAXRECURSION 0);
