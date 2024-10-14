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

-- Q 2. Identify which store had the highest total units sold in the February.
-- First of all we have to make date columns into a right format 

ALter table sales						-- Adding new column named Order_date with date format
add column order_date date;

WITH t AS (
    SELECT 
        *, 
        SUBSTRING_INDEX(date, '/', 1) AS Days, 
        RIGHT(SUBSTRING_INDEX(date, '/', 2), 2) AS Months, 
        RIGHT(date, 4) AS Years
    FROM sales
)
UPDATE sales s
JOIN t ON s.date = t.date
SET s.Order_date = DATE(CONCAT(Years, '-', Months, '-', Days));

alter table sales 
drop date;

-- Now its easy to do any kind of retrieval according to date of particular time span.

SELECT 
    s.store_id, SUM(p.Quantity) AS Quantity_Sold
FROM 
    Sales s
JOIN 
    payment p ON s.Invoice_ID = p.`Invoice ID`
WHERE 
    MONTH(s.order_date) = 2
GROUP BY 
    s.store_id
ORDER BY 
    Quantity_Sold DESC
LIMIT 1;

-- Q.3 Count the number of unique products sold Overall.

SELECT 
	DISTINCT(s.product) as Products, SUM(p.Quantity) AS `Quantity Sold`
FROM 
	sales s
JOIN
	payment p
ON
	s.Invoice_ID = p.`Invoice ID`
GROUP BY 
	1
ORDER BY
	2 DESC;

-- Q. 3 Find the average price of products of Product.

SELECT
	s.Product AS Products, ROUND(AVG(p.unit_price),2) as `Average Sold`
FROM
	sales s
JOIN
	payment p
ON
	s.Invoice_ID = p.`Invoice ID`
GROUP BY
	1
ORDER BY
	2 DESC;
    
-- Q4. Find the Total Revenue by each Store with store details.

SELECT  
	sp.Store_ID as Store_ID, Total_Revenue, Store_Name
				FROM
				(SELECT  
					s.store_id, ROUND(SUM(p.Unit_Price*p.Quantity),2) as Total_Revenue
				FROM
					sales s
				JOIN
					payment p
				ON
					s.Invoice_ID = p.`Invoice ID`
				GROUP BY
					1
				ORDER BY 
					2 DESC) sp
JOIN 
	store_data sd 
ON sp.store_id= sd.Store_Code;

-- Q.5	Identify the least selling product in each store for each month based on total units sold.

WITH t AS (
    SELECT * 
    FROM sales s
    JOIN payment p 
    ON s.invoice_id = p.`Invoice ID`
), 
final AS (
    SELECT 
        store_id, 
        city, 
        product, 
        quantity, 
        MONTH(order_date) AS mon 
    FROM t
), 
h AS (
    SELECT 
        store_id, 
        mon, 
        product, 
        SUM(quantity) AS quantity_sold 
    FROM final 
    GROUP BY 
        product, 
        store_id, 
        mon
), 
g AS (
    SELECT 
        *, 
        RANK() OVER (PARTITION BY store_id, mon ORDER BY quantity_sold) AS rnk 
    FROM h
)
SELECT store_id, mon AS Months, product AS Products, quantity_sold AS Quantity_Sold
FROM g 
WHERE rnk = 1;


 -- Q.6 Idemtify the gender-based product preference analysis.
 
 SELECT 
		s.gender ,s.product, ROUND(SUM(p.Unit_Price* p.Quantity),2) AS Total_Revenue
 FROM 
		sales s
JOIN
		payment p
ON
		s.Invoice_ID = p.`Invoice ID`
GROUP BY 
		2,1;
        
-- Q.7 Find the percentage contribution of each store to overall gross income.



SELECT 
    store_id,
    SUM(gross_income) AS total_store_income,
    (SUM(gross_income) / (0 SUM(gross_income) FROM sales)) * 100 AS percentage_contribution
FROM 
    sales
GROUP BY 
    store_id
ORDER BY 
    percentage_contribution DESC;


