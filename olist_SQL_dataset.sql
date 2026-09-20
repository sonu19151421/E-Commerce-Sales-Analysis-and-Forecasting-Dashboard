show databases;
CREATE database IF NOT EXISTS ecommerce_db;
USE ecommerce_db;
show TABLES;
SELECT database();

DROP table if exists sales;
USE ecommerce_db;

CREATE TABLE sales (
    id                       INT AUTO_INCREMENT PRIMARY KEY,
    order_id                 VARCHAR(50),
    customer_id              VARCHAR(50),
    customer_city            VARCHAR(100),
    customer_state           VARCHAR(50),
    product_id               VARCHAR(50),
    product_category_name    VARCHAR(100),
    price                    FLOAT,
    freight_value            FLOAT,
    total_price              FLOAT,
    payment_value            FLOAT,
    payment_type             VARCHAR(50),
    month                    VARCHAR(20),
    year                     INT,
    quarter                  INT,
    day_of_week              VARCHAR(20),
    order_purchase_timestamp DATETIME
);

DESCRIBE sales;
SELECT count(*) AS total_rows FROM sales;
SELECT * FROM sales LIMIT 10;
DESCRIBE sales;

-- Total Busibess Overview--
SELECT 
count(distinct order_id) AS Total_orders,
count(distinct customer_id) AS Total_customers,
count(distinct product_id) AS Total_products,
count(distinct customer_city) AS Total_cities,
ROUND(sum(price),2) AS total_revenue,
ROUND(avg(price),2) AS avg_total_value,
ROUND(max(price),2) AS max_order_value,
ROUND(min(price),2) AS min_order_value
From sales;

-- Monthly Revenue Trend
Select 
month,
year,
count(distinct order_id) as total_orders,
round(sum(price),2) as total_revenue,
round(avg(price),2) as avg_order_value,
round(sum(freight_value),2) as total_freight
from sales
group by month,year
order by year,month; 

-- year-wise sales comparision 
select 
year,
count(distinct order_id) as total_orders,
round(sum(price),2) as total_revenue,
round(avg(price),2) as avg_order_value,
count(distinct customer_id) as unique_customers 
from sales
group by year;


-- Top 10 Product categories 
select
product_category_name,
count(distinct order_id) as total_orders,
round(sum(price),2) as total_revenue,
round(avg(price),2) as avg_price,
round(sum(price)*100/(select sum(price) from sales),2) as revenue_percentage
from sales
where product_category_name is not null
group by product_category_name
order by total_revenue desc
limit 10;


--  Top 10 cities


SELECT
    customer_city,
    customer_state,
    COUNT(DISTINCT order_id)    AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(SUM(price), 2)        AS total_revenue,
    ROUND(AVG(price), 2)        AS avg_order_value
FROM sales
GROUP BY customer_city, customer_state
ORDER BY total_revenue DESC
LIMIT 10;


-- State wise revenue

SELECT
    customer_state,
    COUNT(DISTINCT order_id)    AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(price), 2)        AS total_revenue,
    ROUND(AVG(price), 2)        AS avg_order_value
FROM sales
GROUP BY customer_state
ORDER BY total_revenue DESC;


-- Payment method analysis

SELECT
    payment_type,
    COUNT(*)                  AS total_transactions,
    ROUND(SUM(price), 2)      AS total_revenue,
    ROUND(AVG(price), 2)      AS avg_payment,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM sales), 2) AS usage_percentage
FROM sales
WHERE payment_type IS NOT NULL
GROUP BY payment_type
ORDER BY total_revenue DESC;


-- Which day has most sales

SELECT
    day_of_week,
    COUNT(DISTINCT order_id)  AS total_orders,
    ROUND(SUM(price), 2)      AS total_revenue,
    ROUND(AVG(price), 2)      AS avg_order_value
FROM sales
GROUP BY day_of_week
ORDER BY total_revenue DESC;


-- Quarterly sales breakdown

SELECT
    year,
    quarter,
    COUNT(DISTINCT order_id)  AS total_orders,
    ROUND(SUM(price), 2)      AS total_revenue,
    ROUND(AVG(price), 2)      AS avg_order_value
FROM sales
GROUP BY year, quarter
ORDER BY year, quarter;


-- Month-over-month growth rate

WITH monthly_revenue AS (
    SELECT
        month,
        year,
        ROUND(SUM(price), 2) AS revenue
    FROM sales
    GROUP BY month, year
    ORDER BY year, month
),
with_lag AS (
    SELECT
        month,
        year,
        revenue,
        LAG(revenue) OVER (ORDER BY year, month) AS prev_month_revenue
    FROM monthly_revenue
)
SELECT
    month,
    year,
    revenue,
    prev_month_revenue,
    ROUND(
        (revenue - prev_month_revenue) * 100.0 / prev_month_revenue,
    2) AS growth_rate_percent
FROM with_lag
WHERE prev_month_revenue IS NOT NULL
ORDER BY year, month;


-- Category wise city analysis


SELECT
    customer_city,
    product_category_name,
    ROUND(SUM(price), 2)      AS revenue,
    COUNT(DISTINCT order_id)  AS orders
FROM sales
WHERE customer_city IN (
    SELECT customer_city
    FROM ( SELECT customer_city 
    FROM sales
    GROUP BY customer_city
    ORDER BY SUM(price) DESC
    LIMIT 5) AS Top_cities
)
AND product_category_name IS NOT NULL
GROUP BY customer_city, product_category_name
ORDER BY customer_city, revenue DESC;

-- Premium orders (above average)

SELECT
    order_id,
    customer_city,
    product_category_name,
    ROUND(price, 2)       AS order_value,
    payment_type,
    month,
    year
FROM sales
WHERE price > (SELECT AVG(price) FROM sales)
ORDER BY price DESC
LIMIT 20;
describe sales;