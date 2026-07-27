-- 0. Clean fact source — exclude the 3 corrupt rows (negatives) and add the derived fields used across the model.
CREATE OR REPLACE VIEW `fmcg.v_fact_sales` AS
SELECT  date,
        sku,
        channel,
        region,
        pack_type,
        promotion_flag,
        price_unit,
        units_sold,
        delivered_qty,
        stock_available,
        ROUND(price_unit * units_sold, 2) AS revenue_proxy,  -- CAVEAT: synthetic price
        IF(stock_available = 0, 1, 0) AS is_stockout
FROM `fmcg.fmcg_sales`
WHERE units_sold >= 0
  AND delivered_qty >= 0
  AND stock_available >= 0

GO 

/*
Result

*/

-- 1. dim_product  (SKU -> brand -> segment -> category) Grain: one row per SKU (expected 30).
CREATE OR REPLACE VIEW `fmcg.dim_product` AS
SELECT  sku,
        ANY_VALUE(brand)    AS brand,
        ANY_VALUE(segment)  AS segment,
        ANY_VALUE(category) AS category
FROM `fmcg.fmcg_sales`
GROUP BY sku

GO 

/*
Result

*/

-- 2. dim_channel / dim_region  (expected 3 rows each)
CREATE OR REPLACE VIEW `fmcg.dim_channel` AS
SELECT DISTINCT channel 
FROM `fmcg.fmcg_sales`

GO 

/*
Result

*/

CREATE OR REPLACE VIEW `fmcg.dim_region` AS
SELECT DISTINCT region 
FROM `fmcg.fmcg_sales`

GO 

/*
Result

*/

-- 3. dim_date  — covers history + forecast window (2022-01-01 .. 2025-03-31)
CREATE OR REPLACE VIEW `fmcg.dim_date` AS
SELECT  d AS date,
        EXTRACT(YEAR FROM d) AS year,
        EXTRACT(QUARTER FROM d) AS quarter,
        EXTRACT(MONTH FROM d) AS month,
        FORMAT_DATE('%B', d) AS month_name,
        EXTRACT(ISOWEEK FROM d) AS iso_week,
        EXTRACT(DAYOFWEEK FROM d) AS dow,
        IF(EXTRACT(DAYOFWEEK FROM d) IN (1, 7), 1, 0) AS is_weekend
FROM UNNEST(GENERATE_DATE_ARRAY(DATE '2022-01-01', DATE '2025-03-31', INTERVAL 1 DAY)) AS d

GO 

/*
Result

*/

-- 4. fact_forecast  — load weekly_forecast_next12w.csv into `fmcg.forecast_raw` (bq load / console), then expose as a view.
CREATE OR REPLACE VIEW `fmcg.fact_forecast` AS
SELECT  sku,
        week AS date,
        forecast_units
FROM `fmcg.forecast_raw`

GO 

/*
Result

*/