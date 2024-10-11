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

with t as 
		(select * from sales s
		join payment p
		on
		s.Invoice_ID = p.`Invoice ID`), 
        final as 
		(select 
			store_id, city,product,quantity,month(order_date) as mon 
		from t), 
		h as 
		(select store_id,mon,product,sum(quantity) 
		as quantity_sold from final 
		group by 
		product, store_id,mon),
		g as 
		(select 
			*,rank() over (partition by  store_id,mon order by quantity_sold) as rnk 
			from h)
select * from g 
	where rnk=1;


with t as 
		(select *,month(order_date) as mon from sales s
		join payment p
		on
		s.Invoice_ID = p.`Invoice ID`)
select distinct * from (select store_id, product, quantity,mon ,sum(quantity) over (partition by product,store_id,mon order by quantity) as quantity_sold from t) j;



