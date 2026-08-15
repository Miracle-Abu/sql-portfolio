SELECT * FROM amazon_sales_dataset;

-- Staging Table
CREATE TABLE amzn_staging
SELECT * FROM amazon_sales_dataset;

SELECT * FROM amzn_staging
LIMIT 100;

-- Search for duplicates
SELECT order_id, COUNT(*) order_count
FROM amzn_staging
GROUP BY order_id
HAVING order_count > 1;

-- Change order_date, ship_date, delivery_date
UPDATE amzn_staging
SET
	order_date = STR_TO_DATE(order_date, '%Y-%m-%d'),
	ship_date = STR_TO_DATE(ship_date, '%Y-%m-%d'),
	delivery_date = STR_TO_DATE(delivery_date, '%Y-%m-%d');
    
    
ALTER TABLE amzn_staging
	MODIFY COLUMN order_date DATE,
    MODIFY COLUMN ship_date DATE,
    MODIFY COLUMN delivery_date DATE;
    
SELECT * FROM amzn_staging
LIMIT 10;

-- Round Total sales to 2dp
UPDATE amzn_staging
SET total_sales = ROUND(total_sales, 2);

-- NULL values in key columns
SELECT 
	SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) order_id,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) order_date,
    SUM(CASE WHEN ship_date IS NULL THEN 1 ELSE 0 END) ship_date,
    SUM(CASE WHEN delivery_date IS NULL THEN 1 ELSE 0 END) delivery_date,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) order_status,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) customer_id,
    SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) customer_name,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) country,
    SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) state,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) city,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) product_id,
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) product_name,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) category,
    SUM(CASE WHEN sub_category IS NULL THEN 1 ELSE 0 END) sub_category,
    SUM(CASE WHEN brand IS NULL THEN 1 ELSE 0 END) brand,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) quantity,
    SUM(CASE WHEN discount IS NULL THEN 1 ELSE 0 END) discount,
    SUM(CASE WHEN shipping_cost IS NULL THEN 1 ELSE 0 END) shipping_cost,
    SUM(CASE WHEN total_sales IS NULL THEN 1 ELSE 0 END) total_sales,
    SUM(CASE WHEN payment_method IS NULL THEN 1 ELSE 0 END) payment_method
FROM amzn_staging;

-- Orders that have delivery_date before ship_date
SELECT Count(*)
FROM amzn_staging
WHERE DATEDIFF(delivery_date, ship_date) < 0;

UPDATE amzn_staging
SET delivery_date = NULL
WHERE delivery_date < ship_date;

-- Check state
SELECT DISTINCT state 
FROM amzn_staging;

-- Update Country to United States
UPDATE amzn_staging
SET country = 'United States'
WHERE country = 'India';

SELECT * FROM amzn_staging
LIMIT 100;

SELECT DISTINCT order_status
FROM amzn_staging;

SELECT DISTINCT category
FROM amzn_staging;

SELECT DISTINCT payment_method
FROM amzn_staging;


-- EDA
-- Total Revenue, Total Orders, Avg Order Value, Total Quantity Sold, Avg Discount
SELECT ROUND(SUM(total_sales), 2) total_revenue, 
	COUNT(*) total_orders,
	ROUND(AVG(total_sales), 2) avg_order_value,
	SUM(quantity) total_quantity_sold,
	ROUND(AVG(discount), 2) avg_discount
FROM amzn_staging;

-- Total Revenue, Total Orders and Average Order Value per category
SELECT category, ROUND(SUM(total_sales), 2) total_revenue, 
	COUNT(*) total_orders,
	ROUND(AVG(total_sales), 2) avg_order_value
FROM amzn_staging
GROUP BY category
ORDER BY total_revenue DESC;

-- Top 10 best selling brands by total revenue and total orders
SELECT brand, ROUND(SUM(total_sales), 2) total_revenue,
	COUNT(*) total_orders
FROM amzn_staging
GROUP BY brand
ORDER BY total_revenue DESC, total_orders DESC
LIMIT 10;

-- Monthly sales trend — total revenue, total orders and average order value per month
SELECT MONTHNAME(order_date), 
	ROUND(SUM(total_sales), 2) total_revenue,
	COUNT(*) total_orders,
    ROUND(AVG(total_sales), 2) avg_order_value
FROM amzn_staging
GROUP BY MONTH(order_date), MONTHNAME(order_date)
ORDER BY MONTH(order_date);


-- The total revenue and total orders per payment method — 
-- and what percentage of total orders does each payment method represent?
WITH payment_CTE AS (
	SELECT payment_method, ROUND(SUM(total_sales), 2) total_revenue,
		COUNT(*) total_orders
	FROM amzn_staging
	GROUP BY payment_method
)
SELECT *, (
  ROUND((total_orders / (SELECT COUNT(*) FROM amzn_staging)) * 100, 2) 
) as order_pct
FROM payment_CTE;

-- The top 10 states by total revenue and total orders
SELECT state, 
	ROUND(SUM(total_sales), 2) total_revenue,
	COUNT(*) total_orders
FROM amzn_staging
GROUP BY state
ORDER BY total_revenue DESC, total_orders DESC
LIMIT 10;

-- Discount Brackets
WITH Discount_CTE AS (
	SELECT *,
		CASE
			WHEN discount = 0 THEN 'No Discount'
			WHEN discount BETWEEN 0.01 AND 0.20 THEN 'Low'
			WHEN discount BETWEEN 0.21 AND 0.40 THEN 'Medium'
			ELSE 'High'
		END AS discount_bracket
	FROM amzn_staging
)
SELECT discount_bracket, ROUND(SUM(total_sales), 2) total_revenue,
	COUNT(*) total_orders,
    ROUND(AVG(total_sales), 2) avg_order_value
FROM Discount_CTE
GROUP BY discount_bracket
ORDER BY total_revenue DESC;

-- Per Sub-Category
SELECT category, sub_category, ROUND(SUM(total_sales), 2) total_revenue,
	COUNT(*) total_orders,
    ROUND(AVG(total_sales), 2) avg_order_value
FROM amzn_staging
GROUP BY category, sub_category
ORDER BY category, total_revenue DESC;

-- TOP 10 Customers
SELECT customer_id, customer_name, ROUND(SUM(total_sales), 2) total_revenue,
	COUNT(*) total_orders
FROM amzn_staging
GROUP BY customer_id, customer_name 
ORDER BY total_revenue DESC, total_orders DESC
LIMIT 10;  

-- Average shipping cost
WITH Shipping_CTE AS (
	SELECT category, ROUND(AVG(shipping_cost), 2) avg_shipping_cost,
		ROUND(AVG(total_sales), 2) avg_order_value
	FROM amzn_staging
	GROUP BY category
) 
SELECT *, (
	ROUND(((avg_shipping_cost/avg_order_value)*100), 2)
) shipping_pct
FROM Shipping_CTE;
