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
-- Explore All Product Categories, Subcategories and product name
SELECT DISTINCT category,
subcategory,
product_name
FROM dim_product;
```
### QUESTION: Show the countries where all our customers come from

<img width="544" height="248" alt="sql 1" src="https://github.com/user-attachments/assets/88782137-8829-4f35-b002-44acb2bf77d7" />

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
```
### QUESTION: Who are our Oldest and Youngest Customers

<img width="479" height="307" alt="sql 2" src="https://github.com/user-attachments/assets/99bd3971-216f-4340-9263-030816001ad3" />

<img width="496" height="323" alt="sql3" src="https://github.com/user-attachments/assets/e63c06c7-9c69-4d42-894c-152ea95083df" />

## Measure Exploration
``` sql
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

-- Find the total number of customers
SELECT COUNT(DISTINCT customer_id) AS total_customers FROM dim_customer;
```

### QUESTION: Find the total number of products we have?

<img width="562" height="189" alt="sql 4" src="https://github.com/user-attachments/assets/35f036eb-09b9-4d79-8c30-5f70ef9472d3" />

### QUESTION: Find the total number of customers who have placed order?

<img width="501" height="257" alt="sql 5" src="https://github.com/user-attachments/assets/9aaa04fb-4f60-4878-bb43-48ee18b6bf90" />

#### Generate a report that shows all key metrics of the business
``` sql
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

-- What is the distribution of sold items across countries
SELECT d.country,
SUM(f.quantity) AS total_quantity
FROM fact_sales f
LEFT JOIN dim_customer d
ON f.customer_key = d.customer_key
GROUP BY d.country
ORDER BY total_quantity DESC;
```

### QUESTION: Find the top 5 customers by total revenue

<img width="443" height="447" alt="SQL 7" src="https://github.com/user-attachments/assets/2d66fec7-f6ca-404e-9bb5-653dc55b1e4c" />

### QUESTION: Find the total Revenue generated by each category

<img width="485" height="308" alt="sql 6" src="https://github.com/user-attachments/assets/55ccccbb-2845-4789-87ad-83739ba0d3fe" />

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

### QUESTION: Find the 5 products with the least revenue

<img width="410" height="357" alt="sql8" src="https://github.com/user-attachments/assets/31e557de-dcd2-4c72-84d6-9ecca61f8a47" />

## Key Findings
- The analysis provided an overview of customer demographics and geographic distribution. Customers are located across six countries, with the United States having the largest customer base. The customer base is also almost evenly split by gender, with males accounting for 50.5% and females 49.3%.
- Product categories differ in product count, average cost, and revenue contribution, highlighting variations in product performance. Components has the largest product portfolio with 127 products, while Accessories has the fewest with 29 products. The Bikes category has the highest average cost at 949.44.
- The analysis identified the highest- and lowest-revenue products, providing insight into products driving overall sales. Mountain-200 Black-46 generated the highest revenue at 1,373,454, while Racing Sock- L generated the lowest at 2,430.
- Customer revenue analysis identified high-value customers and their contribution to overall sales. Kaitlyn Henderson and Nichole Nara were the joint highest-value customers, each generating 13,294 in revenue.




