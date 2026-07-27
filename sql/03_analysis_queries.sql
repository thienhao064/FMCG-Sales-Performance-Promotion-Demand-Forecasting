SET DATEFIRST 1;
GO

--01 Weekly volume trend
SELECT  DATEADD(WEEK, DATEDIFF(WEEK, 0, date), 0) AS week_start,
        SUM(units_sold) AS units
FROM fmcg_sales
WHERE units_sold >= 0
  AND stock_available >= 0
  AND delivered_qty >= 0
GROUP BY DATEADD(WEEK, DATEDIFF(WEEK, 0, date), 0)
ORDER BY week_start

GO

-- 02 YoY volume + growth
WITH yr AS
(
 SELECT YEAR(date) AS yr,
        SUM(units_sold) AS units
 FROM fmcg_sales
 WHERE units_sold >= 0
 GROUP BY YEAR(date)
)

SELECT  yr,
        units,
        ROUND(100 * (units - LAG(units) OVER(ORDER BY yr)) / NULLIF(LAG(units) OVER(ORDER BY yr),0), 1) AS yoy_growth_pct
FROM yr
ORDER BY yr

GO

-- 03 Seasonality - Month
SELECT  MONTH(date) AS month,
        ROUND(AVG(CAST(units_sold AS FLOAT)), 2) AS avg_units
FROM fmcg_sales
WHERE units_sold >= 0
GROUP BY MONTH(date)
ORDER BY month

GO

-- 04 Seasonality - Day of Week
SELECT  DATENAME(WEEKDAY,date) AS day_name,
        DATEPART(WEEKDAY,date) AS dow,
        ROUND(AVG(CAST(units_sold AS FLOAT)), 2) AS avg_units
FROM fmcg_sales
WHERE units_sold >= 0
GROUP BY DATENAME(WEEKDAY,date),
         DATEPART(WEEKDAY,date)
ORDER BY dow

GO

-- 05 Category contribution

SELECT  category,
        SUM(units_sold) AS units,
        ROUND(100 * SUM(units_sold) / SUM(SUM(units_sold)) OVER(), 1) AS pct_of_total
FROM fmcg_sales
WHERE units_sold >= 0
GROUP BY category
ORDER BY units DESC

GO

-- 06 Pareto SKU
SELECT  sku,
        units,
        ROUND(100 * cum_units / tot, 1) AS cum_pct
FROM
(SELECT sku,
        SUM(units_sold) AS units,
        SUM(SUM(units_sold)) OVER (ORDER BY SUM(units_sold) DESC ROWS UNBOUNDED PRECEDING) AS cum_units,
        SUM(SUM(units_sold)) OVER() AS tot
    FROM fmcg_sales
    WHERE units_sold >= 0
    GROUP BY sku) t
ORDER BY units DESC

GO

-- 07 Channel & Region Mix
SELECT  channel,
        region,
        SUM(units_sold) AS units,
        ROUND(100 * SUM(units_sold) / SUM(SUM(units_sold)) OVER(), 1) AS pct_of_total
FROM fmcg_sales
WHERE units_sold >= 0
GROUP BY channel,
         region
ORDER BY units DESC

GO

-- 08 Promotion uplift
WITH g AS
(SELECT category,
        promotion_flag,
        AVG(CAST(units_sold AS FLOAT)) AS avg_units
 FROM fmcg_sales
 WHERE units_sold >= 0
 GROUP BY category,
          promotion_flag
)

SELECT  category,
        MAX(CASE WHEN promotion_flag=0 THEN avg_units END) AS avg_base,
        MAX(CASE WHEN promotion_flag=1 THEN avg_units END) AS avg_promo,
        ROUND(100 * (MAX(CASE WHEN promotion_flag = 1 THEN avg_units END) - MAX(CASE WHEN promotion_flag = 0 THEN avg_units END)) / NULLIF(MAX(CASE WHEN promotion_flag = 0 THEN avg_units END), 0), 1) AS uplift_pct
FROM g
GROUP BY category
ORDER BY uplift_pct DESC

GO

-- 09 Overall promotion share
SELECT  ROUND(100 * AVG(CAST(promotion_flag AS FLOAT)), 1) AS pct_rows_on_promo
FROM fmcg_sales
WHERE units_sold >= 0

GO

-- 10 Stock out analysis
SELECT  ROUND(100 * AVG(CASE WHEN stock_available=0 THEN 1.0 ELSE 0 END), 1) AS stockout_rate_pct,
        SUM(CASE WHEN stock_available=0 THEN 1 ELSE 0 END) AS stockout_rows
FROM fmcg_sales
WHERE units_sold >= 0;

GO

-- 11 Stock out by Channel & Region
SELECT  channel,
        region,
        ROUND(100 * AVG(CASE WHEN stock_available=0 THEN 1 ELSE 0 END), 1) AS stockout_rate_pct
FROM fmcg_sales
WHERE units_sold >= 0
GROUP BY channel,
         region
ORDER BY stockout_rate_pct DESC

GO

-- 12 Monthly stock out trend
SELECT  DATEFROMPARTS(YEAR(date),MONTH(date),1) AS month,
        ROUND(100 * AVG(CASE WHEN stock_available = 0 THEN 1 ELSE 0 END), 1) AS stockout_rate_pct
FROM fmcg_sales
WHERE units_sold >= 0
GROUP BY DATEFROMPARTS(YEAR(date),MONTH(date), 1)
ORDER BY month

GO

-- 13 Top 10 SKU
SELECT  TOP (10)
        sku,
        brand,
        category,
        SUM(units_sold) AS units
FROM fmcg_sales
WHERE units_sold >= 0
GROUP BY sku,
         brand,
         category
ORDER BY units DESC

GO
