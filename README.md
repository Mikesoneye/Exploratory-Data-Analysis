# Exploratory-Data-Analysis

## Project Overview
This project uses MySQL to perform exploratory data analysis, identify key insights, and answer relevant business questions. The analysis involves data cleaning, aggregation, filtering, and SQL queries to generate meaningful insights that support data-driven decision-making.

## Business Question
- Find the total number of customers by countries
- Find total customers by gender
-  Find total products by category
-  What is the average cost in each category
-  hat is the total revenue generated for each category
-  Find the total sales
- find how many items are sold
-  Find the average selling price
-  Find the total number of orders
-  Find the total number of products
-  Find the total number of orders customers
-  Find the total number of customers that has placed order

  ## Dataset Overview
- There are three tables used for this analysis.
  `dim_customers` table  has 18484 rows and 10 columns
 ``` SQL
SELECT COUNT(*) from dim_customer;
DESCRIBE dim_customer;
``` 
`dim_product` table has 295 rows and 11 columns 

 ``` SQL
SELECT COUNT(*) from dim_product;
DESCRIBE dim_product;
```
`fact_sales` table has 60398 rows and 9 columns
``` sql
SELECT COUNT(*) from fact_sales;
DESCRIBE fact_sales;
```
## Tools Used
- MySQL

## Dimension Exploration
``` sql
-- Explore all countries our customers come from
SELECT DISTINCT country FROM dim_customer;

-- Explore All Product Categories, Subcategories and product name
SELECT DISTINCT category,
subcategory,
product_name
FROM dim_product;
```

## Date Exploration
``` sql
-- Find the date of the first and last order
SELECT MIN(order_date) AS first_order_date,
MAX(order_date) AS last_order_date,
timestampdiff(year, MIN(order_date), MAX(order_date)) AS order_date_range
FROM fact_sales;

-- Find the youngest and oldest birthdate
SELECT MIN(birthdate) AS oldest_birthdate,
MAX(birthdate) AS youngest_birthdate
FROM dim_customer;

SELECT timestampdiff(year, MIN(birthdate), CURDATE()) AS oldest_age,
timestampdiff(year, MAX(birthdate), CURDATE()) AS youngest_age
FROM dim_customer;

-- Oldest customer
SELECT distinct first_name,
last_name,
birthdate,
timestampdiff(year, birthdate, CURDATE()) AS oldest_age
FROM dim_customer
WHERE birthdate = (
SELECT MIN(birthdate)
FROM dim_customer);

-- Youngest customers
SELECT first_name,
last_name,
birthdate,
timestampdiff(year, birthdate, CURDATE()) AS oldest_age
FROM dim_customer
WHERE birthdate = (
SELECT MAX(birthdate)
FROM dim_customer);
```

## Measure Exploration
``` sql
-- Find the total sales
SELECT SUM(sales_amount) AS total_sales
FROM fact_sales;

-- Find how many items are sold
SELECT COUNT(quantity) AS no_of_items_sold
FROM fact_sales;

-- Find the average selling price
SELECT AVG(price) AS avg_selling_price
FROM fact_sales;

-- Find the total number of orders
SELECT COUNT(DISTINCT order_number) AS total_orders FROM fact_sales;
SELECT COUNT(order_number) AS total_orders FROM fact_sales;

-- Find the total number of products
SELECT COUNT(DISTINCT product_id) AS total_orders FROM dim_product;

-- Find the total number of orders customers
SELECT COUNT(DISTINCT customer_id) AS total_orders FROM dim_customer;

-- Find the total number of customers that has placed order
SELECT COUNT(DISTINCT d.customer_id) AS purchasing_customers
FROM fact_sales f
LEFT JOIN dim_customer d
ON f.customer_key = d.customer_key
WHERE order_number IS NOT NULL;
```

## Generate a report that shows all key metrics of the business
``` sql
SELECT 'Total sales' as measure_name, SUM(sales_amount) AS measure_value FROM fact_sales
UNION ALL
SELECT 'Total Quantity' as measure_name, COUNT(quantity) AS measure_value FROM fact_sales
UNION ALL
SELECT 'Average price' as measure_name, AVG(price) AS measure_value FROM fact_sales
UNION ALL
SELECT 'Total Orders' as measure_name, COUNT(DISTINCT order_number) AS measure_value FROM fact_sales
UNION ALL
SELECT 'Total products' as measure_name, COUNT(DISTINCT product_id) AS measure_value FROM dim_product
UNION ALL
SELECT 'Total customers' as measure_name, COUNT(DISTINCT customer_id) AS measure_value FROM dim_customer;
```

## Magnitude Exploration
``` sql
-- Find the total number of customers by countries
SELECT country,
COUNT(DISTINCT customer_id) AS total_customers
FROM dim_customer
GROUP BY country
ORDER BY total_customers DESC;

-- Find total customers by gender
SELECT gender,
COUNT( DISTINCT customer_id) AS total_customers
FROM dim_customer
GROUP BY gender;

-- Find total products by category
SELECT category,
COUNT(DISTINCT product_id) AS total_products
FROM dim_product
GROUP BY category
ORDER BY total_products DESC;

-- What is the average cost in each category
SELECT category,
AVG(cost) AS average_cost
FROM dim_product
GROUP BY category
ORDER BY average_cost DESC;

-- What is the total revenue generated for each category
SELECT d.category,
SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
LEFT JOIN dim_product d
ON f.product_key = d.product_key
GROUP BY category;

-- Find total revenue generated by each customer
SELECT d.first_name,
d.last_name,
d.customer_id,
SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
LEFT JOIN dim_customer d
ON f.customer_key = d.customer_key
GROUP BY d.first_name,
d.last_name,
d.customer_id
ORDER BY total_revenue DESC;

-- What is the distribution of sold items across countries
SELECT d.country,
SUM(f.quantity) AS total_quantity
FROM fact_sales f
LEFT JOIN dim_customer d
ON f.customer_key = d.customer_key
GROUP BY d.country
ORDER BY total_quantity DESC;
```

## Ranking Analysis
``` sql
-- Which 5 products generate the highest revenue
SELECT d.product_name,
SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
LEFT JOIN dim_product d
ON f.product_key = d.product_key
GROUP BY d.product_name
ORDER BY total_revenue DESC
LIMIT 5;

-- Which 5 products generate the lowest revenue
SELECT d.product_name,
SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
LEFT JOIN dim_product d
ON f.product_key = d.product_key
GROUP BY d.product_name
ORDER BY total_revenue
LIMIT 5;
 -- second method using window function
 SELECT d.product_name,
SUM(f.sales_amount)AS total_revenue,
ROW_NUMBER() OVER(ORDER BY SUM(f.sales_amount) DESC) AS ranked_products
FROM fact_sales f
LEFT JOIN dim_product d
ON f.product_key = d.product_key
GROUP BY d.product_name
LIMIT 5;

-- Find the top 10 customers who have generated highest revenue using Window function
SELECT d.first_name,
d.last_name,
d.customer_id,
SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
LEFT JOIN dim_customer d
ON f.customer_key = d.customer_key
GROUP BY d.first_name, d.last_name, d.customer_id 
ORDER BY total_revenue DESC
LIMIT 10;

-- Find the top 3 customers with lowest revenue
SELECT *
FROM (
	SELECT *,
	RANK() OVER(ORDER BY total_revenue) AS ranked_position
	FROM (
		SELECT d.first_name,
		d.last_name,
		d.customer_id,
		SUM(f.sales_amount) AS total_revenue
		FROM fact_sales f
		LEFT JOIN dim_customer d
		ON f.customer_key = d.customer_key
		GROUP BY d.first_name,
		d.last_name,
		d.customer_id) AS customer_revenue
      ) AS ranked_customer
WHERE ranked_position <= 3
LIMIT 3;
```



