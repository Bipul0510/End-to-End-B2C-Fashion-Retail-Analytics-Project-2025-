-- SQL Problems and Solutions for table `fashion_transactions_2025` based on detected columns
-- Detected columns: order_id, order_date, customer_id, age, gender, city, category, subcategory, brand, price, quantity, discount, final_price, channel, return_flag, rating, revenue

-- 1. Count total transactions
SELECT COUNT(*) AS total_transactions FROM fashion_transactions_2025;

-- 2. Compute total revenue
SELECT ROUND(SUM(revenue), 2) AS total_revenue FROM fashion_transactions_2025;

-- 3. Average order value (AOV)
SELECT ROUND(AVG(revenue), 2) AS avg_order_value FROM fashion_transactions_2025;

-- 4. Monthly revenue trend (YYYY-MM)
SELECT STRFTIME('%Y-%m', order_date) AS year_month,
       ROUND(SUM(revenue),2) AS revenue
FROM fashion_transactions_2025
GROUP BY year_month
ORDER BY year_month;

-- 5. Revenue by category and share of total
WITH cat AS (
  SELECT category AS category, SUM(revenue) AS revenue
  FROM fashion_transactions_2025
  GROUP BY category
)
SELECT category,
       ROUND(revenue,2) AS revenue,
       ROUND(100.0 * revenue / SUM(revenue) OVER (), 2) AS pct_of_total
FROM cat
ORDER BY revenue DESC;

-- 6. Top 10 brands by revenue
SELECT brand AS brand, ROUND(SUM(revenue),2) AS revenue
FROM fashion_transactions_2025
GROUP BY brand
ORDER BY revenue DESC
LIMIT 10;

-- 7. Revenue by sales channel
SELECT channel AS channel, ROUND(SUM(revenue),2) AS revenue
FROM fashion_transactions_2025
GROUP BY channel
ORDER BY revenue DESC;

-- 8. Revenue by location (city)
SELECT city, ROUND(SUM(revenue),2) AS revenue
FROM fashion_transactions_2025
GROUP BY city
ORDER BY revenue DESC;

-- 9. Top 10 customers by lifetime revenue
SELECT customer_id AS customer, ROUND(SUM(revenue),2) AS revenue
FROM fashion_transactions_2025
GROUP BY customer_id
ORDER BY revenue DESC
LIMIT 10;
