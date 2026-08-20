CREATE DATABASE Datahouse;
USE Datahouse;

CREATE TABLE dim_customer(
	customer_key int,
	customer_id int,
	customer_number varchar(50),
	first_name varchar(50),
	last_name varchar(50),
	country varchar(50),
	marital_status varchar(50),
	gender varchar(50),
	birthdate date,
	create_date date
);

LOAD DATA LOCAL INFILE "C:/Users/paragon/Documents/sql-data-analytics-project/sql-data-analytics-project/datasets/flat-files/dim_customers.csv"
INTO TABLE dim_customer FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS;

UPDATE dim_customer
SET birthdate = null
WHERE birthdate = 0;


SHOW GLOBAL VARIABLES LIKE 'local_file';
SET GLOBAL local_infile = 1;

SELECT * FROM dim_customer limit 5;

CREATE TABLE dim_product(
product_key int ,
	product_id int ,
	product_number varchar(50) ,
	product_name varchar(50) ,
	category_id varchar(50) ,
	category varchar(50) ,
	subcategory varchar(50) ,
	maintenance varchar(50) ,
	cost int,
	product_line varchar(50),
	start_date varchar(15) 
);
LOAD DATA LOCAL INFILE "C:/Users/paragon/Documents/sql-data-analytics-project/sql-data-analytics-project/datasets/flat-files/dim_products.csv"
INTO TABLE dim_product FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS;


CREATE TABLE fact_sales(
order_number varchar(50),
	product_key int,
	customer_key int,
	order_date varchar (20),
	shipping_date date,
	due_date date,
	sales_amount int,
	quantity tinyint,
	price int
);
LOAD DATA LOCAL INFILE "C:/Users/paragon/Documents/sql-data-analytics-project/sql-data-analytics-project/datasets/flat-files/fact_sales.csv"
INTO TABLE fact_sales FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS;


SELECT order_date,
str_to_date(order_date, '%Y-%m-%d')
FROM fact_sales
LIMIT 20;

UPDATE fact_sales 
SET order_date = null
WHERE Year(order_date) = 0;

describe fact_sales;

SET GLOBAL local_infile = 1;

-- ===============================================
-- Explore All Objects in the Database
-- ===============================================
SELECT * FROM INFORMATION_SCHEMA.TABLES;


-- ===============================================
-- Explore All Columns in the Database
-- ===============================================
SELECT * FROM INFORMATION_SCHEMA.COLUMNS;


-- ===============================================
-- Dimension Exploration
-- ===============================================
-- Explore all countries our customers come from
SELECT DISTINCT country FROM dim_customer;

-- Explore All Product Categories, Subcategories and product name
SELECT DISTINCT category,
subcategory,
product_name
FROM dim_product;


-- ===============================================
-- Date Exploration
-- ===============================================
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
timestampdiff(year, birthdate, CURDATE()) AS youngest_age
FROM dim_customer
WHERE birthdate = (
SELECT MAX(birthdate)
FROM dim_customer);


-- ===============================================
-- Measures Exploration
-- ===============================================
-- Find the total sales
-- Find how many items are sold
-- Find the average selling price
-- Find the total number of orders
-- Find the total number of products
-- Find the total number of orders customers
-- Find the total number of customers that has placed order
-- Generate a report that shows all key metrics of the business

-- Find the total sales
SELECT SUM(sales_amount) AS total_sales
FROM fact_sales;

-- Find how many items are sold
SELECT SUM(quantity) AS total_items_sold
FROM fact_sales;

-- Find the average selling price
SELECT AVG(price) AS avg_selling_price
FROM fact_sales;

-- Find the total number of orders
SELECT COUNT(DISTINCT order_number) AS total_orders FROM fact_sales;
SELECT COUNT(order_number) AS total_orders FROM fact_sales;

-- Find the total number of products
SELECT COUNT(DISTINCT product_id) AS total_products FROM dim_product;

-- Find the total number of customers
SELECT COUNT(DISTINCT customer_id) AS total_customers FROM dim_customer;

-- Find the total number of customers that has placed order
SELECT COUNT(DISTINCT d.customer_id) AS purchasing_customers
FROM fact_sales f
LEFT JOIN dim_customer d
ON f.customer_key = d.customer_key
WHERE order_number IS NOT NULL;

-- Generate a report that shows all key metrics of the business
SELECT 'Total sales' as measure_name, SUM(sales_amount) AS measure_value FROM fact_sales
UNION ALL
SELECT 'Total Quantity' as measure_name, SUM(quantity) AS measure_value FROM fact_sales
UNION ALL
SELECT 'Average price' as measure_name, AVG(price) AS measure_value FROM fact_sales
UNION ALL
SELECT 'Total Orders' as measure_name, COUNT(DISTINCT order_number) AS measure_value FROM fact_sales
UNION ALL
SELECT 'Total products' as measure_name, COUNT(DISTINCT product_id) AS measure_value FROM dim_product
UNION ALL
SELECT 'Total customers' as measure_name, COUNT(DISTINCT customer_id) AS measure_value FROM dim_customer;


-- ===============================================
-- Magnitude Exploration
-- ===============================================
-- Find the total number of customers by countries
-- Find total customers by gender
-- Find total products by category
-- What is the average cost in each category
-- What is the total revenue generated for each category
-- Find total revenue generated by each customer
-- What is the distribution of sold items across countries


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
GROUP BY category
ORDER BY total_revenue DESC;

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
ORDER BY total_revenue DESC
LIMIT 5;

-- What is the distribution of sold items across countries
SELECT d.country,
SUM(f.quantity) AS total_quantity
FROM fact_sales f
LEFT JOIN dim_customer d
ON f.customer_key = d.customer_key
GROUP BY d.country
ORDER BY total_quantity DESC;


-- ===============================================
-- Ranking Analysis
-- ===============================================
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
