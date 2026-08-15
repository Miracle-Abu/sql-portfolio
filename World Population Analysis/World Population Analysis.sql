-- WORLD POPULATION ANALYSIS
SELECT * 
FROM world_population_table;

-- STAGING TABLE
CREATE TABLE world_population_1
LIKE world_population_table;

SELECT * 
FROM world_population_1;

INSERT INTO world_population_1
SELECT *
FROM world_population_table;

-- EDA

-- What are the top 10 most populated and top 10 least populated countries in 2022?
SELECT `Country/Territory`, `2022 Population` 
FROM world_population_1
WHERE `Rank` BETWEEN 1 AND 10
ORDER BY `2022 Population` DESC;

SELECT `Country/Territory`, `2022 Population` 
FROM world_population_1
ORDER BY `2022 Population` 
LIMIT 10;


-- What is the total population, average population, average density and average growth rate per continent in 2022? 
SELECT Continent, SUM(`2022 Population`) `Total Population`, ROUND(AVG(`2022 Population`), 2) `Average Population`, 
ROUND(AVG(`Density (per km²)`), 2) `Average Density`, ROUND(AVG(`Growth Rate`), 2) `Average Growth Rate`
FROM world_population_1
GROUP BY Continent
ORDER BY `Total Population` DESC;


-- Which countries grew the fastest between 1970 and 2022?
SELECT `Country/Territory`, Continent, `1970 Population`, `2022 Population`,
(`2022 Population` - `1970 Population`) `Absolute Growth`, ROUND(((`2022 Population` - `1970 Population`)/`1970 Population`) * 100, 2) `Percentage Growth (%)`
FROM world_population_1
ORDER BY `Percentage Growth (%)` DESC
LIMIT 15;

-- Which are the top 10 most densely populated and top 10 least densely populated countries in 2022?
SELECT `Country/Territory`, Continent, `2022 Population`, `Area (km²)`, `Density (per km²)`
FROM world_population_1
WHERE `Area (km²)` != 0
ORDER BY `Density (per km²)` DESC
LIMIT 10;

SELECT `Country/Territory`, Continent, `2022 Population`, `Area (km²)`, `Density (per km²)`
FROM world_population_1
WHERE `Area (km²)` != 0
ORDER BY `Density (per km²)`
LIMIT 10;


SELECT *
FROM world_population_1;

-- Which countries dominate world population share?
SELECT `Country/Territory`, Continent, `2022 Population`, `World Population Percentage`,
SUM(`World Population Percentage`) OVER(ORDER BY `World Population Percentage` DESC) `Running Total (%)`,
CASE
	WHEN `World Population Percentage` > 5 THEN 'Major Power'
    WHEN `World Population Percentage` BETWEEN 1 AND 5 THEN 'Significant'
    WHEN `World Population Percentage` BETWEEN 0.1 AND 1 THEN 'Moderate'
	ELSE 'Small'
END AS population_dominance
FROM world_population_1
ORDER BY `World Population Percentage` DESC;


-- How has the world's total population changed across all recorded time periods?
WITH Population_Over_Time AS (
	SELECT 1970 AS `year`, SUM(`1970 Population`) `Total Population`
	FROM world_population_1
	UNION ALL
	SELECT 1980 AS `year`, SUM(`1980 Population`) `Total Population`
	FROM world_population_1
	UNION ALL
	SELECT 1990 AS `year`, SUM(`1990 Population`) `Total Population`
	FROM world_population_1
	UNION ALL
	SELECT 2000 AS `year`, SUM(`2000 Population`) `Total Population`
	FROM world_population_1
	UNION ALL
	SELECT 2010 AS `year`, SUM(`2010 Population`) `Total Population`
	FROM world_population_1
	UNION ALL
	SELECT 2015 AS `year`, SUM(`2015 Population`) `Total Population`
	FROM world_population_1
	UNION ALL
	SELECT 2020 AS `year`, SUM(`2020 Population`) `Total Population`
	FROM world_population_1
	UNION ALL
	SELECT 2022 AS `year`, SUM(`2022 Population`) `Total Population`
	FROM world_population_1
)
SELECT *,
`Total Population` - LAG(`Total Population`) OVER(ORDER BY `year`) `Population Growth`
FROM Population_Over_Time;


-- What are the top 3 most populated countries per continent in 2022?
WITH Continent_Rank AS (
	SELECT Continent, `Country/Territory`, `2022 Population`,
    DENSE_RANK() OVER(PARTITION BY Continent ORDER BY `2022 Population` DESC) `Continent Rank`
	FROM world_population_1
)
SELECT *
FROM Continent_Rank
WHERE `Continent Rank` < 4;


-- Fastest growing vs declining populations
SELECT `Country/Territory`, `2022 Population`, `Growth Rate`,
CASE
	WHEN `Growth Rate` > 1.02 THEN 'Rapidly Growing'
    WHEN `Growth Rate` BETWEEN 1.00 AND 1.02 THEN 'Slowly Growing'
    ELSE 'Declining'
END AS `Growth Band`
FROM world_population_1;

WITH Growth_Summary AS (
	SELECT `Country/Territory`, `2022 Population`, `Growth Rate`,
	CASE
		WHEN `Growth Rate` > 1.02 THEN 'Rapidly Growing'
		WHEN `Growth Rate` BETWEEN 1.00 AND 1.02 THEN 'Slowly Growing'
		ELSE 'Declining'
	END AS `Growth Band`
	FROM world_population_1
)
SELECT `Growth Band`, COUNT(`Country/Territory`) `No. of Countries`, AVG(`2022 Population`) `Average 2022 Population`
FROM Growth_Summary
GROUP BY `Growth Band`
ORDER BY `Average 2022 Population` DESC;

