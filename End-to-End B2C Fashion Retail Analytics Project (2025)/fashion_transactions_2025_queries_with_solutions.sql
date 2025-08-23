-- Fashion Transactions 2025 — Problem Statements WITH Solutions
-- Assumed table name: fashion_transactions_2025
-- Columns: order_id (text), order_date (text dd-mm-yyyy), customer_id (text), age (int),
--          gender (text), city (text), category (text), subcategory (text), brand (text),
--          price (numeric), quantity (int), discount (numeric, percent 0-100),
--          final_price (numeric), channel (text), return_flag (int/bool), rating (numeric)

/*--------------------------------------------------------------------
1) Top 10 best-selling subcategory items by total quantity.
--------------------------------------------------------------------*/
SELECT subcategory,
       SUM(quantity) AS total_qty
FROM fashion_transactions_2025
GROUP BY subcategory
ORDER BY total_qty DESC
FETCH FIRST 10 ROWS ONLY;

/*--------------------------------------------------------------------
2) Monthly revenue trend for 2025 using order_date (dd-mm-yyyy).
   (Adjust date functions to your SQL engine as needed.)
--------------------------------------------------------------------*/
SELECT TO_CHAR(TO_DATE(order_date, 'DD-MM-YYYY'), 'YYYY-MM') AS year_month,
       SUM(final_price) AS revenue
FROM fashion_transactions_2025
WHERE TO_CHAR(TO_DATE(order_date, 'DD-MM-YYYY'), 'YYYY') = '2025'
GROUP BY TO_CHAR(TO_DATE(order_date, 'DD-MM-YYYY'), 'YYYY-MM')
ORDER BY year_month;

/*--------------------------------------------------------------------
3) Average order value (AOV) per customer.
--------------------------------------------------------------------*/
SELECT customer_id,
       AVG(final_price) AS avg_order_value
FROM fashion_transactions_2025
GROUP BY customer_id
ORDER BY avg_order_value DESC;

/*--------------------------------------------------------------------
4) Top 5 cities by total revenue.
--------------------------------------------------------------------*/
SELECT city,
       SUM(final_price) AS revenue
FROM fashion_transactions_2025
GROUP BY city
ORDER BY revenue DESC
FETCH FIRST 5 ROWS ONLY;

/*--------------------------------------------------------------------
5) Most returned category (highest number of return_flag = 1).
--------------------------------------------------------------------*/
SELECT category,
       SUM(CASE WHEN return_flag = 1 THEN 1 ELSE 0 END) AS returns
FROM fashion_transactions_2025
GROUP BY category
ORDER BY returns DESC
FETCH FIRST 1 ROW ONLY;

/*--------------------------------------------------------------------
6) Discount impact: compare revenue before vs after discount.
--------------------------------------------------------------------*/
SELECT
  SUM(price * quantity)                                       AS gross_amount,
  SUM(final_price)                                            AS net_amount,
  (SUM(price * quantity) - SUM(final_price))                  AS discount_impact,
  CASE WHEN SUM(price * quantity) = 0 THEN 0
       ELSE ROUND( (SUM(price * quantity) - SUM(final_price)) * 100.0 / SUM(price * quantity), 2)
  END AS discount_pct
FROM fashion_transactions_2025;

/*--------------------------------------------------------------------
7) Age group segments and their purchase patterns (qty & revenue).
--------------------------------------------------------------------*/
WITH seg AS (
  SELECT CASE
           WHEN age < 20 THEN 'Under 20'
           WHEN age BETWEEN 20 AND 29 THEN '20s'
           WHEN age BETWEEN 30 AND 39 THEN '30s'
           WHEN age BETWEEN 40 AND 49 THEN '40s'
           WHEN age BETWEEN 50 AND 59 THEN '50s'
           ELSE '60+'
         END AS age_band,
         quantity,
         final_price
  FROM fashion_transactions_2025
)
SELECT age_band,
       SUM(quantity) AS total_qty,
       SUM(final_price) AS total_revenue,
       ROUND(AVG(final_price), 2) AS avg_order_value
FROM seg
GROUP BY age_band
ORDER BY total_revenue DESC;

/*--------------------------------------------------------------------
8) Most popular sales channel by order count and revenue.
--------------------------------------------------------------------*/
SELECT channel,
       COUNT(*) AS orders,
       SUM(final_price) AS revenue
FROM fashion_transactions_2025
GROUP BY channel
ORDER BY revenue DESC;

/*--------------------------------------------------------------------
9) Brand-wise average rating with minimum volume filter (>= 100 orders).
--------------------------------------------------------------------*/
SELECT brand,
       AVG(rating) AS avg_rating,
       COUNT(*)    AS orders
FROM fashion_transactions_2025
GROUP BY brand
HAVING COUNT(*) >= 100
ORDER BY avg_rating DESC;

/*--------------------------------------------------------------------
10) Repeat customers (customers with > 5 orders) and their KPIs.
--------------------------------------------------------------------*/
WITH c AS (
  SELECT customer_id,
         COUNT(*) AS orders,
         SUM(final_price) AS revenue,
         ROUND(AVG(final_price), 2) AS avg_order_value
  FROM fashion_transactions_2025
  GROUP BY customer_id
)
SELECT *
FROM c
WHERE orders > 5
ORDER BY revenue DESC;

/*--------------------------------------------------------------------
11) Category contribution to revenue (share %).
--------------------------------------------------------------------*/
WITH r AS (
  SELECT SUM(final_price) AS total_rev FROM fashion_transactions_2025
)
SELECT f.category,
       SUM(f.final_price) AS category_rev,
       ROUND(SUM(f.final_price) * 100.0 / (SELECT total_rev FROM r), 2) AS share_pct
FROM fashion_transactions_2025 f
GROUP BY f.category
ORDER BY category_rev DESC;

/*--------------------------------------------------------------------
12) Return rate by category.
--------------------------------------------------------------------*/
SELECT category,
       ROUND(AVG(CASE WHEN return_flag = 1 THEN 1.0 ELSE 0.0 END) * 100.0, 2) AS return_rate_pct
FROM fashion_transactions_2025
GROUP BY category
ORDER BY return_rate_pct DESC;

/*--------------------------------------------------------------------
13) Customer LTV proxy: total revenue per customer.
--------------------------------------------------------------------*/
SELECT customer_id,
       SUM(final_price) AS revenue
FROM fashion_transactions_2025
GROUP BY customer_id
ORDER BY revenue DESC;

/*--------------------------------------------------------------------
14) Monthly cohort of first purchase (cohort revenue in 2025 sample).
--------------------------------------------------------------------*/
WITH first_purchase AS (
  SELECT
    customer_id,
    MIN(TO_DATE(order_date, 'DD-MM-YYYY')) AS first_dt
  FROM fashion_transactions_2025
  GROUP BY customer_id
),
orders_2025 AS (
  SELECT f.*,
         TO_CHAR(TO_DATE(f.order_date, 'DD-MM-YYYY'), 'YYYY-MM') AS ym
  FROM fashion_transactions_2025 f
  WHERE TO_CHAR(TO_DATE(f.order_date, 'DD-MM-YYYY'), 'YYYY') = '2025'
)
SELECT TO_CHAR(first_dt, 'YYYY-MM') AS cohort_month,
       ym AS order_month,
       SUM(o.final_price) AS revenue
FROM orders_2025 o
JOIN first_purchase fp USING (customer_id)
GROUP BY TO_CHAR(first_dt, 'YYYY-MM'), ym
ORDER BY cohort_month, order_month;
