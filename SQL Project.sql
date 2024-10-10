-- Walmart Data Analysis using SQL 

-- Creating a Databases
CREATE DATABASE big_sales;

-- Importing all the Data using Import wizard 
-- Using Database
use big_sales;
-- Checking all the tables
select * from sales;
select * from payment;
select * from store_data;



show tables;
select * from payment;

-- Q 1.	Calculate the total number of units sold by each store.

SELECT 
	s.store_id ,SUM(p.quantity) as Quantity_Sold from sales s
JOIN payment p
GROUP BY 1 
Order by 2 DESC;

