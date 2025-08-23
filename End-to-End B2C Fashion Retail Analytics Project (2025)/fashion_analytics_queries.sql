-- Fashion Retail Analytics SQL Queries (2025)

-- Project Title: End-to-End B2C Fashion Retail Analytics


create database fashion_transactions_2025

use fashion_transactions_2025

select * from fashion_transactions_2025


-- Task 1: High-level KPIs

/* Purpose: total revenue, orders count, unique customers, average order value (AOV)  */

SELECT
  (SUM("price" * COALESCE("quantity",1))) AS total_sales,
  COUNT(DISTINCT "order_id") AS total_orders,
  COUNT(DISTINCT "customer_id") AS unique_customers,
  (SUM("price" * COALESCE("quantity",1)) * 1.0 / NULLIF(COUNT(DISTINCT "order_id"),0)) AS avg_order_value
FROM "fashion_transactions_2025";



-- Task 2: Monthly sales trend

/* Purpose: Group sales by month (YYYY-MM) showing total sales and order count.  */

SELECT strftime('%Y-%m', "order_date") AS year_month,
       COUNT(DISTINCT "order_id") AS orders,
       SUM(("price" * COALESCE("quantity",1))) AS total_sales
FROM "fashion_transactions_2025"
GROUP BY year_month
ORDER BY year_month;



-- Task 3: Top 10 products by revenue

/* Purpose: Sum revenue per product and show top 10.  */

-- NOTE: Replace "product" with actual product column (e.g., product_name, product_id, sku)
SELECT "product" AS product, COUNT(DISTINCT "order_id") AS orders, SUM(("price" * COALESCE("quantity",1))) AS revenue
FROM "fashion_transactions_2025"
GROUP BY "product"
ORDER BY revenue DESC
LIMIT 10;



-- Task 4: Top 10 cities by revenue

/* Purpose: Aggregate revenue by city, show top 10 cities.  */

-- NOTE: Requires city column
SELECT "city" AS city, SUM(("price" * COALESCE("quantity",1))) AS revenue, COUNT(DISTINCT "order_id") AS orders
FROM "fashion_transactions_2025"
GROUP BY "city"
ORDER BY revenue DESC
LIMIT 10;



-- Task 5: Repeat purchase rate

/* Purpose: Percent of customers with more than one distinct order.  */

WITH c AS (
   SELECT "customer_id", COUNT(DISTINCT "order_id") AS orders_per_customer
   FROM "fashion_transactions_2025"
   GROUP BY "customer_id"
)
SELECT
  SUM(CASE WHEN orders_per_customer > 1 THEN 1 ELSE 0 END)*1.0 / COUNT(*) AS repeat_rate,
  COUNT(*) AS total_customers
FROM c;



-- Task 6: Returns rate by product/category
/* Purpose: If a return flag exists, compute return counts and rates per product.  */
-- NOTE: Requires return_flag and product/category column
SELECT "product" AS product_or_item,
       SUM(CASE WHEN "return_flag" IN (1,'1','Y','y','Yes','yes','TRUE') THEN 1 ELSE 0 END) AS num_returns,
       COUNT(*) AS transactions,
       ROUND( SUM(CASE WHEN "return_flag" IN (1,'1','Y','y','Yes','yes','TRUE') THEN 1.0 ELSE 0 END) / NULLIF(COUNT(*),0), 4) AS return_rate
FROM "fashion_transactions_2025"
GROUP BY "product"
ORDER BY return_rate DESC
LIMIT 20;


-- Task 7: AOV by store/payment
/* Purpose: Compute AOV grouped by store or payment method.  */
-- NOTE: Requires store or payment column
SELECT "store" AS channel, COUNT(DISTINCT "order_id") AS orders, 
       SUM(("price" * COALESCE("quantity",1))) AS total_sales,
       (SUM(("price" * COALESCE("quantity",1)))*1.0 / NULLIF(COUNT(DISTINCT "order_id"),0)) AS aov
FROM "fashion_transactions_2025"
GROUP BY "store"
ORDER BY total_sales DESC
LIMIT 20;


-- Task 8: Promotion impact
/* Purpose: Compare average order value and total sales for promo-coded orders vs non-promo.  */
-- NOTE: Requires promo column
WITH o AS (
  SELECT "order_id" AS oid, "promo" AS promo, SUM(("price" * COALESCE("quantity",1))) AS order_total
  FROM "fashion_transactions_2025"
  GROUP BY "order_id", "promo"
)
SELECT CASE WHEN promo IS NOT NULL AND promo <> '' THEN 'promo' ELSE 'no_promo' END AS promo_flag,
       COUNT(*) AS orders, AVG(order_total) AS avg_order_value, SUM(order_total) AS total_sales
FROM o
GROUP BY promo_flag;




-- Task 9: Customer lifetime value basics
/* Purpose: For each customer compute total spend, number of orders, and average line value.  */

SELECT "customer_id" AS customer,
       COUNT(DISTINCT "order_id") AS order_count,
       SUM(("price" * COALESCE("quantity",1))) AS total_spend,
       AVG(("price" * COALESCE("quantity",1))) AS avg_line_value
FROM "fashion_transactions_2025"
GROUP BY "customer_id"
ORDER BY total_spend DESC
LIMIT 20;




-- Task 10: Category x Month sales pivot
/* Purpose: Aggregate sales by product category and month to prepare pivot/heatmap.  */

SELECT "category" AS category, strftime('%Y-%m', "order_date") AS year_month, SUM(("price" * COALESCE("quantity",1))) AS total_sales
FROM "fashion_transactions_2025"
GROUP BY "category", year_month
ORDER BY "category", year_month;

