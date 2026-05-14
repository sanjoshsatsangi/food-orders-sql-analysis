SELECT * FROM food_Data
--Data Validation & Cleaning 
-- Null Check
SELECT
SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_state,
SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,
SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
SUM(CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) AS null_restaurant,
SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS null_location,
SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS null_category,
SUM(CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) AS null_dish, 
SUM(CASE WHEN Price_INR IS NULL THEN 1 ELSE 0 END) AS null_price, 
SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
SUM(CASE WHEN Rating_Count IS NULL THEN 1 ELSE 0 END) AS null_rating_count
FROM food_data;


-- Blank or	Empty Strings
Select * 
FROM food_data
WHERE
State ='' OR City='' OR Restaurant_Name ='' OR Location= '' OR Dish_Name=''


--Duplicate Detection
SELECT
State, City, order_date, restaurant_name, location, category,
dish_name, price_INR, rating, rating_count, count(*) as CNT
FROM food_data
GROUP BY
State, City, order_date, restaurant_name, location, category,
dish_name, price_INR, rating, rating_count
HAVING count(*)>1

--Delete Duplication
WITH CTE AS(
SELECT *, ROW_NUMBER() OVER(
	PARTITION BY State, City, order_date, restaurant_name, location, category,
dish_name, price_INR, rating, rating_count
ORDER BY (SELECT NULL)
) AS rn
FROM food_data
)
DELETE FROM CTE WHERE rn>1


--CREATE SCHEMA
--DIMENSION TABLES
--DATA TABLE

CREATE TABLE dim_date(
	date_id INT IDENTITY(1,1) PRIMARY KEY,
	Full_Date DATE,
	Year INT,
	Month INT,
	Month_Name varchar(20),
	Quarter INT,
	Day INT,
	Week INT
	)

	SELECT * FROM dim_date

--dim_location
CREATE TABLE dim_location (
	location_id INT IDENTITY (1,1) PRIMARY KEY, 
	State VARCHAR(100), 
	City VARCHAR(100), 
	Location VARCHAR(200)
);

--dim_restaurant
CREATE TABLE dim_restaurant (
	restaurant_id INT IDENTITY (1,1) PRIMARY KEY, 
	Restaurant_Name VARCHAR(200)
); 


--dim_category
CREATE TABLE dim_category( 
category_id INT IDENTITY(1,1) PRIMARY KEY, 
Category VARCHAR(200)
);

--dim dish
CREATE TABLE dim_dish ( 
dish_id INT IDENTITY(1,1) PRIMARY KEY, 
Dish_Name VARCHAR(200)
);



--FACT TABLE
CREATE TABLE fact_food_orders (
order_id INT IDENTITY(1,1) PRIMARY KEY,


date_id INT,
Price_INR DECIMAL (10,2),
Rating DECIMAL(4,2),
Rating_Count INT,


location_id INT,
restaurant_id INT,
category_id INT,
dish_id INT,


FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
FOREIGN KEY (location_id) REFERENCES dim_location (location_id),
FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant (restaurant_id),
FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)
);


--INSERT DATA

--dim_date
INSERT INTO dim_date (Full_Date, Year, Month, Month_Name, Quarter, Day, Week)
SELECT DISTINCT
	Order_Date,
	YEAR (Order_Date),
	MONTH (Order_Date),
	DATENAME (MONTH, Order_Date),
	DATEPART(QUARTER, Order_Date),
	DAY (Order_Date),
	DATEPART(WEEK,Order_Date)
FROM food_Data
WHERE Order_Date IS NOT NULL;


--dim_location
INSERT INTO dim_location (State, City, Location)
SELECT DISTINCT
	State,
	City,
	Location
FROM food_Data;

--dim restaurant
INSERT INTO dim_restaurant (Restaurant_Name)
SELECT DISTINCT
	Restaurant_Name
From food_Data;

--dim category
INSERT INTO dim_category (Category)
SELECT DISTINCT
	Category
From food_Data;

--dim Dish
INSERT INTO dim_dish (Dish_Name)
SELECT DISTINCT
	Dish_Name
From food_Data;

SELECT * FROM dim_location



--fact_table
INSERT INTO fact_food_orders
(
	date_id,
	Price_INR,
	Rating,
	Rating_Count,
	location_id,
	restaurant_id,
	category_id,
	dish_id
)

SELECT
	dd.date_id,
	s.Price_INR, 
	s.Rating, 
	s.Rating_Count,


	dl.location_id,
	dr.restaurant_id,
	dc.category_id,
	dsh.dish_id
FROM food_Data s

JOIN dim_date dd
	ON dd.Full_Date = s.Order_Date

JOIN dim_location dl
	ON dl.State = s.State
	AND dl.City = s.CITY
	AND dl.Location = s.Location

JOIN dim_restaurant dr
	ON dr.Restaurant_Name = s.Restaurant_Name

JOIN dim_category dc
	ON dc.Category = s.Category

JOIN dim_dish dsh
	ON dsh.Dish_Name = s.Dish_Name

SELECT * FROM fact_food_orders f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_location l ON f.location_id = l.location_id
JOIN dim_restaurant r ON f.restaurant_id = r.restaurant_id
JOIN dim_category c ON f.category_id = c.category_id
JOIN dim_dish di ON f.dish_id = di.dish_id


--KPI's
--Total Orders
SELECT COUNT(*) AS Total_Orders
FROM fact_food_orders

-- Total Revenue (INR Million)
SELECT 
FORMAT(SUM (Convert(FLOAT,price_INR)) /1000000, 'N2') + ' INR Million' 
AS Total_Revenue 
FROM fact_food_orders

--Average Dish Price
SELECT 
FORMAT(AVG (Convert(FLOAT,price_INR)), 'N2') + ' INR' 
AS Total_Revenue 
FROM fact_food_orders

-- Average Rating
SELECT
AVG(Rating) AS Avg_Rating
FROM fact_food_orders

--Deep-Dive Business Analysis

--Monthly Order Trends
SELECT
d.year,
d.month,
d.month_name,
COUNT(*) AS Total_Orders
FROM fact_food_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY
d.year,
d.month,
d.month_name
ORDER BY count(*) DESC

SELECT
d.year,
d.month,
d.month_name,
SUM(Price_INR) AS Total_Orders
FROM fact_food_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY
d.year,
d.month,
d.month_name
ORDER BY SUM(Price_INR) DESC


--Quaterly Trend
SELECT
d.year,
d.quarter,
COUNT(*) AS Total_Orders
FROM fact_food_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY
d.year,
d.quarter
ORDER BY count(*) DESC

--Yearly Trend
SELECT
d.year,
COUNT(*) AS Total_Orders
FROM fact_food_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY
d.year
ORDER BY count(*) DESC

--order by day of the week (Mon-Sun)
SELECT
	DATENAME(WEEKDAY, d.full_date) AS day_name,
	COUNT(*) AS total_orders
FROM fact_food_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY DATENAME(WEEKDAY, d.full_date), DATEPART (WEEKDAY, d.full_date)
ORDER BY DATEPART(WEEKDAY, d.full_date);

--Top 10 Cities by order volume
SELECT TOP 10
l.city,
COUNT(*) AS Total_Orders FROM fact_food_orders f
JOIN dim_location l
ON l.location_id = f.location_id
GROUP BY l.city
ORDER BY COUNT(*) DESC

--Revenue contribution by states
SELECT
l.state,
SUM(f.price_INR) AS Total_Orders FROM fact_food_orders f
JOIN dim_location l
ON l.location_id = f.location_id
GROUP BY l.state
ORDER BY SUM(f.price_INR) DESC

--TOP 10 restaurants by orders
SELECT TOP 10
r.restaurant_name,
SUM(f.price_INR) AS Total_Orders FROM fact_food_orders f
JOIN dim_restaurant r
ON r.restaurant_id = f.restaurant_id
GROUP BY r.restaurant_name
ORDER BY SUM(f.price_INR) DESC

--TOP Categories by Order Value
SELECT TOP 10
	c.category,
	COUNT(*) AS total_orders
FROM fact_food_orders f
JOIN dim_category c ON f.category_id = c.category_id
GROUP BY c.Category
ORDER BY total_orders DESC;

--Most Ordered Dishes
SELECT TOP 10
	d.dish_name,
	COUNT(*) AS order_count
FROM fact_food_orders f
JOIN dim_dish d ON f.dish_id = d.dish_id
GROUP BY d.Dish_Name
ORDER BY order_count DESC;

--Cuisine Performance (Orders + Avg Rating
SELECT
	c.category,
	COUNT(*) AS total_orders,
	AVG(f.rating) AS avg_rating
FROM fact_food_orders f
JOIN dim_category c ON f.category_id = c.category_id
GROUP BY c.Category
ORDER BY total_orders DESC


--TOTAL Orders by Price Range
SELECT
	CASE
		WHEN CONVERT(FLOAT, price_INR) < 100 THEN 'Under 100'
		WHEN CONVERT (FLOAT, price_INR) BETWEEN 100 AND 199 THEN '100 - 199'
		WHEN CONVERT(FLOAT, price_INR) BETWEEN 200 AND 299 THEN '200 - 299'
		WHEN CONVERT(FLOAT, price_INR) BETWEEN 300 AND 499 THEN '300 - 499'
		ELSE '500+'
	END AS price_range,
	COUNT(*) AS total_orders
FROM fact_food_orders
GROUP BY
	CASE
		WHEN CONVERT (FLOAT, price_INR) < 100 THEN 'Under 100'
		WHEN CONVERT(FLOAT, price_INR) BETWEEN 100 AND 199 THEN '100 - 199'
		WHEN CONVERT (FLOAT, price_INR) BETWEEN 200 AND 299 THEN '200 - 299'
		WHEN CONVERT(FLOAT, price_INR) BETWEEN 300 AND 499 THEN '300 - 499'
		ELSE '500+'
	END
ORDER BY total_orders DESC;

--Rating Count Distribution (1-5)
SELECT
	rating,
	COUNT(*) AS rating_count
FROM fact_food_orders
GROUP BY rating
ORDER BY COUNT(*) DESC;
