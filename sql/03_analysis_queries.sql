-- Q1. Weekly volume trend
SELECT
    DATE_TRUNC(date, WEEK(MONDAY)) AS week_start,
    SUM(units_sold) AS units
FROM fmcg.fmcg_sales
WHERE units_sold >= 0 
  AND stock_available >= 0 
  AND delivered_qty >= 0
GROUP BY week_start
ORDER BY week_start

GO 

/*
Result

*/

-- Q2. Year-over-year volume + growth
WITH yr AS (
  SELECT EXTRACT(YEAR FROM date) AS yr, 
         SUM(units_sold) AS units
  FROM fmcg.fmcg_sales
  WHERE units_sold >= 0
  GROUP BY yr
)
SELECT yr, units,
       ROUND(SAFE_DIVIDE(units - LAG(units) OVER (ORDER BY yr), LAG(units) OVER (ORDER BY yr)) * 100, 1) AS yoy_growth_pct
FROM yr
ORDER BY yr

GO 

/*
Result

*/

-- Q3. Seasonality: month-of-year and day-of-week (avg units per row)
SELECT EXTRACT(MONTH FROM date) AS month, 
       ROUND(AVG(units_sold),2) AS avg_units
FROM fmcg.fmcg_sales WHERE units_sold >= 0
GROUP BY month 
ORDER BY month

GO 

/*
Result

*/

SELECT FORMAT_DATE('%A', date) AS day_name,
       EXTRACT(DAYOFWEEK FROM date) AS dow,
       ROUND(AVG(units_sold),2) AS avg_units
FROM fmcg.fmcg_sales 
WHERE units_sold >= 0
GROUP BY day_name, dow 
ORDER BY dow

GO 

/*
Result

*/

-- Q4. Product-hierarchy contribution (category share of volume)
SELECT category,
       SUM(units_sold) AS units,
       ROUND(100 * SUM(units_sold) / SUM(SUM(units_sold)) OVER (), 1) AS pct_of_total
FROM fmcg.fmcg_sales 
WHERE units_sold >= 0
GROUP BY category 
ORDER BY units DESC

GO 

/*
Result

*/

-- Pareto: SKUs ranked, cumulative share
SELECT sku, 
       units, 
       ROUND(100*cum_units/tot,1) AS cum_pct
FROM (
  SELECT sku, 
         SUM(units_sold) AS units,
         SUM(SUM(units_sold)) OVER (ORDER BY SUM(units_sold) DESC) AS cum_units,
         SUM(SUM(units_sold)) OVER () AS tot
  FROM fmcg.fmcg_sales 
  WHERE units_sold >= 0
  GROUP BY sku
)
ORDER BY units DESC

GO 

/*
Result

*/

-- Q5. Channel & region mix
SELECT channel, 
       region,
       SUM(units_sold) AS units,
       ROUND(100 * SUM(units_sold) / SUM(SUM(units_sold)) OVER (), 1) AS pct_of_total
FROM fmcg.fmcg_sales 
WHERE units_sold >= 0
GROUP BY channel, region
ORDER BY units DESC

GO 

/*
Result

*/

-- Q6. Promotion uplift on volume (overall + by category)
-- uplift% = (avg_promo - avg_base) / avg_base
WITH g AS (
  SELECT category, 
         promotion_flag, 
         AVG(units_sold) AS avg_units
  FROM fmcg.fmcg_sales 
  WHERE units_sold >= 0
  GROUP BY category, promotion_flag
)
SELECT
  category,
  MAX(IF(promotion_flag=0, avg_units, NULL)) AS avg_base,
  MAX(IF(promotion_flag=1, avg_units, NULL)) AS avg_promo,
  ROUND(100 * SAFE_DIVIDE(MAX(IF(promotion_flag=1, avg_units, NULL)) - MAX(IF(promotion_flag=0, avg_units, NULL)), MAX(IF(promotion_flag=0, avg_units, NULL))), 1) AS uplift_pct
FROM g
GROUP BY category
ORDER BY uplift_pct DESC

GO 

/*
Result

*/

-- overall promo share of rows
SELECT ROUND(100*AVG(promotion_flag),1) AS pct_rows_on_promo
FROM fmcg.fmcg_sales 
WHERE units_sold >= 0;

GO 

/*
Result

*/

-- Q7. Stock-out analysis
-- stock-out proxy = stock_available = 0
SELECT
  ROUND(100*AVG(IF(stock_available=0,1,0)),1) AS stockout_rate_pct,
  COUNTIF(stock_available=0) AS stockout_rows
FROM fmcg.fmcg_sales 
WHERE units_sold >= 0

GO 

/*
Result

*/

SELECT channel, 
       region,
       ROUND(100*AVG(IF(stock_available=0,1,0)),1) AS stockout_rate_pct
FROM fmcg.fmcg_sales 
WHERE units_sold >= 0
GROUP BY channel, region
ORDER BY stockout_rate_pct DESC

GO 

/*
Result

*/

-- Monthly stock-out trend
SELECT DATE_TRUNC(date, MONTH) AS month,
       ROUND(100*AVG(IF(stock_available = 0,1,0)),1) AS stockout_rate_pct
FROM fmcg.fmcg_sales 
WHERE units_sold >= 0
GROUP BY month 
ORDER BY month

GO 

/*
Result

*/

-- Q8. Top / bottom SKUs by volume
SELECT  sku, 
        brand, 
        category, 
        SUM(units_sold) AS units
FROM fmcg.fmcg_sales 
WHERE units_sold >= 0
GROUP BY sku, brand, category
ORDER BY units DESC
LIMIT 10;

GO 

/*
Result

*/