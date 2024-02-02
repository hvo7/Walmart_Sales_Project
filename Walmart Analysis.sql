USE Walmart

SELECT *
FROM Walmart_Sales;

-- Count number of rowss
SELECT Count(Date)
FROM Walmart_Sales;

-- Check Date Range
SELECT DISTINCT(Date)
FROM Walmart_Sales
ORDER BY Date;

----------- Data Cleaning ---------

-- Change Format of Date to mm-dd-yyyy if different formats

/*
UPDATE Walmart_Sales
SET [Date] = 
CASE
	When [Date] LIKE '%/%/%' THEN CONVERT(VARCHAR(20), CONVERT(DATE, [Date], 101), 110)
	WHEN [Date] LIKE '%-%-%' THEN CONVERT(VARCHAR(20), CONVERT(DATE, [Date], 105), 110)
	ELSE [Date]
END
Where [Date] IS NOT NULL;
*/

--ALTER TABLE Walmart_Sales
--ALTER COLUMN [Date] Date;

--Check Null Values
SELECT *
FROM Walmart_Sales
WHERE Temperature IS NULL OR Fuel_Price IS NULL OR CPI IS NULL OR Unemployment IS NULL
ORDER BY Date;

---- What are the weeks and weekly sales when there is a holiday?

SELECT DISTINCT [Date]
FROM Walmart_Sales
WHERE Holiday_Flag = 1;

-- Change the dates by swapping the month and day such that the holiday_flag is accurate (Week has Labour Day, Super Bowl, Thanksgiving, or Christmas)
-- 2010-10-09 -> 2010-09-10 
-- 2010-12-02 -> 2010-02-12

-- 2011-11-02 -> 2011-02-11

-- 2012-07-09 -> 2012-09-07
-- 2012-10-02 -> 2012-02-10

/*
UPDATE Walmart_Sales
SET [Date] = FORMAT(CONVERT(Date, [Date], 23), 'yyyy-dd-MM')
WHERE [Holiday_Flag] = 1 AND [Date] IN ('2010-12-02', '2010-10-09', '2011-11-02', '2012-07-09', '2012-10-02')
*/

-- What are the weekly_sales on Labour Day for each store?

SELECT [Store],[Weekly_Sales], [Date]
FROM Walmart_Sales
WHERE [Date] LIKE '%-09-%' AND [Holiday_Flag] = 1
ORDER BY [Date], [Store];

--What is the average weekly sales during the week of Christmas for each store? And how does it compare to the weekly sales of other individual years?
SELECT [Store], [Weekly_Sales], [Date],  AVG(Weekly_Sales) OVER (Partition By Store) AS AvgChristmasSales
FROM Walmart.dbo.Walmart_Sales
WHERE [Date] LIKE '%-12-%' AND [Holiday_Flag] = 1

-- What are the annual sales for each store for 2010?

SELECT [Store], Sum([Weekly_Sales]) AS Annual_Sales
FROM Walmart_Sales
WHERE [Date] LIKE '2010%'
GROUP BY Store

-- How are the weekly_sales for when it is hot vs. when it is cold?


WITH Temperature_Sales AS (
	SELECT [Store], 
			[Date], 
			[Weekly_Sales],
			[Temperature],
			CASE
				WHEN Temperature >= 75 THEN 'Hot'
				ELSE 'Cold'
			END AS Temperature_Type
FROM Walmart_Sales
)

SELECT [Store], 
		[Date], 
		[Weekly_Sales],
		[Temperature], 
		[Temperature_Type],
		Round(Max(Weekly_Sales) OVER (Partition By Temperature_Type),2) AS Max_Sales, 
		Round(AVG(Weekly_Sales) OVER (Partition By Temperature_Type),2) AS Avg_Sales, 
		Round(Min(Weekly_Sales) OVER (Partition By Temperature_Type),2) AS Min_Sales
FROM Temperature_Sales
ORDER By [Date]

-- How does fuel price affect sales?
-- Does a high fuel price dissuade customers?

SELECT [Fuel_Price],
		Avg(Weekly_Sales) AS Avg_Sales
From Walmart_Sales
GROUP BY [Fuel_Price]
ORDER BY [Fuel_Price] DESC

-- What Stores produce the most/least average amount of weekly sales?

SELECT [Store], 
		ROUND(AVG(Weekly_Sales),2) AS Avg_Sales
FROM Walmart_Sales
GROUP BY [Store]
ORDER BY Avg_Sales DESC

-- How might sales look for each season throughout the year for each store?
WITH Seasonal_Sales AS (
	SELECT [Store], 
			[Date], 
			[Weekly_Sales], 
			CASE
				WHEN MONTH(Date) IN (12,1,2) THEN 'Winter' 
				WHEN MONTH(Date) IN (3,4,5) THEN 'Spring'
				WHEN MONTH(Date) IN (6,7,8) Then 'Summer'
				Else 'Fall'
			END AS 'Season'
	FROM Walmart_Sales
)


-- Show the average sales of each store in winter 


/*
SELECT 
		[Store], 
		Round(Avg(Weekly_Sales),2) AS Avg_Sales,
		[Season]
FROM Seasonal_Sales
WHERE Season = 'Winter'
GROUP BY [Store], Season
ORDER BY Avg_Sales DESC
*/


-- What are the amount of sales for each season of ALL STORES?

SELECT 
	[Season],
	ROUND(Avg(Weekly_Sales),2) AS Avg_Sales
FROM Seasonal_Sales
GROUP BY [Season]