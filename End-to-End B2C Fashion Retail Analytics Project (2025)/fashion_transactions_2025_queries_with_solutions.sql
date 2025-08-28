-- Fashion Transactions 2025 — Problem Statements WITH Solutions

-- Table name: fashion_transactions_2025

-- Columns: order_id (text), order_date (text dd-mm-yyyy), customer_id (text), age (int),
--          gender (text), city (text), category (text), subcategory (text), brand (text),
--          price (numeric), quantity (int), discount (numeric, percent 0-100),
--          final_price (numeric), channel (text), return_flag (int/bool), rating (numeric)


create database fashion_transactions_2025

use fashion_transactions_2025

select * from fashion_transactions_2025

/*--------------------------------------------------------------------
1) Total revenue, orders count, unique customers, average order value (AOV).
--------------------------------------------------------------------*/

SELECT
  round(SUM(final_price),2) as total_sales,
  COUNT(DISTINCT "order_id") as total_orders,
  COUNT(DISTINCT "customer_id") as unique_customers,
  round(avg(final_price),2) as avg_order_value
FROM "fashion_transactions_2025";



/*--------------------------------------------------------------------
2) Top 10 best-selling subcategory items by total quantity.
--------------------------------------------------------------------*/
SELECT top 10 subcategory,
       SUM(quantity) as total_qty

FROM fashion_transactions_2025
GROUP BY subcategory
ORDER BY 2 DESC


/*--------------------------------------------------------------------
3) Monthly revenue trend for 2025 using order_date (dd-mm-yyyy).
   (Adjust date functions to your SQL engine as needed.)
--------------------------------------------------------------------*/
SELECT fORMAT(order_date, 'yyyy-MM') as year_month,
       COUNT(DISTINCT "order_id") as orders,
       ROUND(SUM(final_price),2) as Total_revenue
FROM fashion_transactions_2025
GROUP BY fORMAT(order_date, 'yyyy-MM') 
ORDER BY year_month;

--OR

SELECT DATENAME(MONTH, order_date) + ' ' + CAST(YEAR(order_date) as VARCHAR(4)) as month,
       COUNT(DISTINCT "order_id") as orders,
       ROUND(SUM(final_price),2) as Total_revenue

FROM fashion_transactions_2025
GROUP BY DATENAME(MONTH, order_date), YEAR(order_date), MONTH(order_date)
ORDER BY month;

/*--------------------------------------------------------------------
4) Average order value (AOV) per customer.
--------------------------------------------------------------------*/
SELECT customer_id,
       AVG(final_price) as avg_order_value
FROM fashion_transactions_2025
GROUP BY customer_id
ORDER BY 2 DESC;

/*--------------------------------------------------------------------
5) Top 5 cities by total revenue.
--------------------------------------------------------------------*/
SELECT top 5 city,
       round(SUM(final_price),2) as Total_revenue
FROM fashion_transactions_2025
GROUP BY city
ORDER BY 2 DESC

/*--------------------------------------------------------------------
6) Most returned category (highest number of return_flag = 1).
--------------------------------------------------------------------*/
SELECT category,
       SUM(CASE WHEN return_flag = 1 THEN 1 ELSE 0 END) as total_returns
FROM fashion_transactions_2025
GROUP BY category
ORDER BY 2 DESC

/*--------------------------------------------------------------------
7) Discount impact: compare revenue before vs after discount.
--------------------------------------------------------------------*/
SELECT     SUM(price * quantity) as gross_amount,
           Round(SUM(final_price),2) as net_amount,
		   Round((SUM(price * quantity) - SUM(final_price)),2) as discount_impact,
		   CASE 
		   WHEN SUM(price * quantity) = 0 THEN 0 ELSE ROUND( (SUM(price * quantity) - SUM(final_price)) * 100.0 / SUM(price * quantity), 2)
           END AS discount_pct
FROM fashion_transactions_2025;

/*--------------------------------------------------------------------
8) Age group segments and their purchase patterns (qty & revenue).
--------------------------------------------------------------------*/
WITH seg as (
  SELECT CASE
           WHEN age < 20 THEN 'Under 20'
           WHEN age BETWEEN 20 AND 29 THEN '20-30'
           WHEN age BETWEEN 30 AND 39 THEN '30-40'
           WHEN age BETWEEN 40 AND 49 THEN '40-50'
           WHEN age BETWEEN 50 AND 59 THEN '50-60'
           ELSE 'Above 60'
         END as age_band,
         quantity,
         final_price
  FROM fashion_transactions_2025
)
SELECT age_band,
       SUM(quantity) as total_qty,
       ROUND(SUM(final_price),2) as total_revenue,
       ROUND(AVG(final_price), 2) as avg_order_value
FROM seg
GROUP BY age_band
ORDER BY 3 DESC;

/*--------------------------------------------------------------------
9) Most popular sales channel by order count and revenue.
--------------------------------------------------------------------*/
SELECT channel,
       COUNT(*) AS order_count,
       round(SUM(final_price),2) as Total_revenue
FROM fashion_transactions_2025
GROUP BY channel
ORDER BY 3 DESC;

/*--------------------------------------------------------------------
10) Brand-wise average rating with minimum volume filter (>= 100 orders).
--------------------------------------------------------------------*/
SELECT brand,
       AVG(rating) as avg_rating,
       COUNT(*)    as orders
FROM fashion_transactions_2025
GROUP BY brand
HAVING COUNT(*) >= 100
ORDER BY 2 DESC;

/*--------------------------------------------------------------------
11) Repeat customers (customers with > 5 orders) and their KPIs.
--------------------------------------------------------------------*/
WITH cid as (
  SELECT customer_id,
         COUNT(*) as orders,
         ROUND(SUM(final_price),2) as revenue,
         ROUND(AVG(final_price), 2) as avg_order_value
  FROM fashion_transactions_2025
  GROUP BY customer_id
)
SELECT *
FROM cid
WHERE orders > 5
ORDER BY 3 DESC;

/*--------------------------------------------------------------------
12) Category contribution to revenue (share %).
--------------------------------------------------------------------*/
WITH r AS (
  SELECT SUM(final_price) as total_rev FROM fashion_transactions_2025
)
SELECT f.category,
       ROUND(SUM(f.final_price),2) as category_rev,
       ROUND(SUM(f.final_price) * 100.0 / (SELECT total_rev FROM r), 2) as share_pct
FROM fashion_transactions_2025 f
GROUP BY f.category
ORDER BY category_rev DESC;

/*--------------------------------------------------------------------
13) Return rate by category.
--------------------------------------------------------------------*/
SELECT category,
       ROUND(AVG(CASE WHEN return_flag = 1 THEN 1.0 ELSE 0.0 END) * 100.0, 2) as return_rate_pct
FROM fashion_transactions_2025
GROUP BY category
ORDER BY return_rate_pct DESC;

/*--------------------------------------------------------------------
14) Customer LTV proxy: total revenue per customer.
--------------------------------------------------------------------*/
SELECT customer_id,
       round(SUM(final_price),2) as revenue
FROM fashion_transactions_2025
GROUP BY customer_id
ORDER BY revenue DESC;

/*--------------------------------------------------------------------
15) Monthly cohort of first purchase (cohort revenue in 2025 sample).
--------------------------------------------------------------------*/
WITH first_purchase as (
    SELECT
        customer_id,
        MIN(order_date) as first_dt
    FROM fashion_transactions_2025
    GROUP BY customer_id
),
orders_2025 as (
    SELECT
        f.customer_id,
        f.order_date,
        (f.price * ISNULL(f.quantity, 1)) as final_price,
        FORMAT(f.order_date, 'yyyy-MM') as order_month
    FROM fashion_transactions_2025 f
    WHERE YEAR(f.order_date) = 2025
)
SELECT 
    FORMAT(fp.first_dt, 'yyyy-MM') as cohort_month,
    o.order_month,
    SUM(o.final_price) as revenue
FROM orders_2025 o
JOIN first_purchase fp 
    ON o.customer_id = fp.customer_id
GROUP BY FORMAT(fp.first_dt, 'yyyy-MM'), o.order_month
ORDER BY cohort_month, order_month;

--------------------------------------------------NEXT STEP IS THE VISUALISATION OF THESE PROBLEM STATEMENTS--------------------------------------------------------

