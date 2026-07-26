-- Query 1: Row count & date coverage
SELECT
    COUNT(*) AS row_count,
    MIN([date]) AS min_date,
    MAX([date]) AS max_date,
    COUNT(DISTINCT date) AS distinct_days
FROM fmcg_sales

GO
/*
Result Query 1:
- row_count = 190757
- min_date = 2022-01-21
- max_date = 2024-12-31
- distinct_days = 1076
*/

-- Query 2: Missing / NULL values per column
SELECT
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS null_date,
    SUM(CASE WHEN sku IS NULL THEN 1 ELSE 0 END) AS null_sku,
    SUM(CASE WHEN brand IS NULL THEN 1 ELSE 0 END) AS null_brand,
    SUM(CASE WHEN segment IS NULL THEN 1 ELSE 0 END) AS null_segment,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN channel IS NULL THEN 1 ELSE 0 END) AS null_channel,
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS null_region,
    SUM(CASE WHEN pack_type IS NULL THEN 1 ELSE 0 END) AS null_pack_type,
    SUM(CASE WHEN price_unit IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN promotion_flag IS NULL THEN 1 ELSE 0 END) AS null_promo,
    SUM(CASE WHEN delivery_days IS NULL THEN 1 ELSE 0 END) AS null_delivery,
    SUM(CASE WHEN stock_available IS NULL THEN 1 ELSE 0 END) AS null_stock,
    SUM(CASE WHEN delivered_qty IS NULL THEN 1 ELSE 0 END) AS null_delivered,
    SUM(CASE WHEN units_sold IS NULL THEN 1 ELSE 0 END) AS null_units
FROM fmcg_sales

GO
/*
Result Query 2:
All zeros
*/

-- Query 3: Duplicate business key
SELECT
    date,
    sku,
    channel,
    region,
    pack_type,
    COUNT(*) AS n
FROM fmcg_sales
GROUP BY
    [date],
    sku,
    channel,
    region,
    pack_type
HAVING COUNT(*) > 1
ORDER BY n DESC

GO
/*
Result Query 3:
All zeros
*/

-- Query 4: Out-of-range / negative numeric values
SELECT COUNT(*) AS error_rows
FROM fmcg_sales
WHERE price_unit < 0
   OR units_sold < 0
   OR delivered_qty < 0
   OR stock_available < 0
   OR delivery_days < 0
   OR promotion_flag NOT IN (0,1)

GO
/*
Result Query 4:
error_rows = 3
*/

-- Query 5: Distinct values of categorical dimensions
SELECT
    'channel' AS dim,
    channel AS value,
    COUNT(*) AS n
FROM fmcg_sales
GROUP BY channel
UNION ALL
SELECT
    'region',
    region,
    COUNT(*)
FROM fmcg_sales
GROUP BY region
UNION ALL
SELECT
    'pack_type',
    pack_type,
    COUNT(*)
FROM fmcg_sales
GROUP BY pack_type
UNION ALL
SELECT
    'category',
    category,
    COUNT(*)
FROM fmcg_sales
GROUP BY category
ORDER BY dim, n DESC

GO
/*
Result Query 5:
dim "category" >> value "Yogurt" >> n 72707
dim "category" >> value "Milk" >> n 44595
dim "category" >> value "ReadyMeal" >> n 34236
dim "category" >> value "SnackBar" >> n 32276
dim "category" >> value "Juice" >> n 6943
dim "channel" >> value "Retail" >> n 63688
dim "channel" >> value "E-commerce" >> n 63619
dim "channel" >> value "Discount" >> n 63450
dim "pack_type" >> value "Carton" >> n 63671
dim "pack_type" >> value "Multipack" >> n 63550
dim "pack_type" >> value "Single" >> n 63536
dim "region" >> value "PL-North" >> n 63645
dim "region" >> value "PL-South" >> n 63567
dim "region" >> value "PL-Central" >> n 63545
*/

-- Query 6: Product-hierarchy consistency
SELECT
    sku,
    COUNT(DISTINCT brand) AS n_brand,
    COUNT(DISTINCT segment) AS n_segment,
    COUNT(DISTINCT category) AS n_category
FROM fmcg_sales
GROUP BY sku
HAVING COUNT(DISTINCT brand) > 1
    OR COUNT(DISTINCT segment) > 1
    OR COUNT(DISTINCT category) > 1

GO
/*
Result Query 6:
zeros
*/

-- Query 7: Sold more than available stock
SELECT COUNT(*) AS sold_gt_stock
FROM fmcg_sales
WHERE units_sold > stock_available

GO
/*
Result Query 7:
sold_gt_stock = 119888
*/

-- Query 8: Stock-out incidence
SELECT
    SUM(CASE WHEN units_sold = 0 THEN 1 ELSE 0 END) AS zero_sales_rows,
    SUM(CASE WHEN units_sold = 0 AND stock_available = 0 THEN 1 ELSE 0 END) AS zero_sales_no_stock,
    SUM(CASE WHEN units_sold = 0 AND stock_available > 0 THEN 1 ELSE 0 END) AS zero_sales_with_stock,
    ROUND(
        100.0 * SUM(CASE WHEN units_sold = 0 THEN 1 ELSE 0 END) / COUNT(*),
        1
    ) AS pct_zero_sales
FROM fmcg_sales

GO
/*
Result Query 8:
zero_sales_rows = 3862
zero_sales_no_stock = 3860
zero_sales_with_stock = 2
pct_zero_sales = 2.0
*/

-- Query 9: New SKUs by first appearance year
SELECT
    first_year,
    COUNT(*) AS n_skus
FROM (SELECT
          sku,
          YEAR(MIN([date])) AS first_year
      FROM fmcg_sales
      GROUP BY sku) t
GROUP BY first_year
ORDER BY first_year

GO
/*
Result Query 9:
first_year 2022 >> n_skus 20
first_year 2022 >> n_skus 10
*/

-- Query 10: Price drift across years
SELECT
    YEAR([date]) AS year,
    ROUND(AVG(price_unit), 2) AS avg_price,
    ROUND(MIN(price_unit), 2) AS min_price,
    ROUND(MAX(price_unit), 2) AS max_price
FROM fmcg_sales
GROUP BY YEAR([date])
ORDER BY year

GO
/*
Result Query 10:
year 2022 >> avg_price 5.25 >> min_price 1.5 >> max_price 9
year 2023 >> avg_price 5.26 >> min_price 1.5 >> max_price 9
year 2024 >> avg_price 5.25 >> min_price 1.5 >> max_price 9
*/