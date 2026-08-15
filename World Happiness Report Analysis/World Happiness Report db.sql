DROP DATABASE IF EXISTS `World_Happiness_Report`;
CREATE DATABASE `World_Happiness_Report`;
USE `World_Happiness_Report`;

SELECT * 
FROM `2015_report`;

CREATE TABLE `2015_report_1` -- Staging table
SELECT * 
FROM `2015_report`;

SELECT * 
FROM `2015_report_1`;

-- CLEANING (IF ANY)
SELECT Region, Count(*)
FROM `2015_report_1`
GROUP BY Region
ORDER BY 2;

SELECT Country, Count(*) country_count
FROM `2015_report_1`
GROUP BY Country
HAVING country_count != 1
ORDER BY 2;

-- EDA
-- What region has the highest average hapiness score
SELECT Region, ROUND(AVG(`Happiness Score`), 2) `Average Happiness Score`, 
RANK() OVER(ORDER BY AVG(`Happiness Score`) DESC) `Happiness Rank`
FROM `2015_report_1`
GROUP BY Region;

-- What country in each of these regions is happiest
WITH Regional_Rank AS (
	SELECT Country, Region, `Happiness Score`,
	RANK() OVER(PARTITION BY Region ORDER BY `Happiness Score` DESC) `Rank Per Region`
	FROM `2015_report_1`
	GROUP BY Country, Region, `Happiness Score`
)
SELECT *
FROM Regional_Rank
WHERE `Rank Per Region` = 1;

-- Top 5 happiest countries in each region
WITH Regional_Rank AS (
	SELECT Country, Region, `Happiness Score`,
	RANK() OVER(PARTITION BY Region ORDER BY `Happiness Score` DESC) `Rank Per Region`
	FROM `2015_report_1`
	GROUP BY Country, Region, `Happiness Score`
)
SELECT *
FROM Regional_Rank
WHERE `Rank Per Region` BETWEEN 1 AND 5;

-- Top 5 Unhappiest
WITH Regional_Rank AS (
	SELECT Country, Region, `Happiness Score`,
	RANK() OVER(PARTITION BY Region ORDER BY `Happiness Score`) `Unhappiness Rank`
	FROM `2015_report_1`
	GROUP BY Country, Region, `Happiness Score`
)
SELECT *
FROM Regional_Rank
WHERE `Unhappiness Rank` = 1;

-- Least happy country per region
WITH Regional_Rank AS (
	SELECT Country, Region, `Happiness Score`,
	RANK() OVER(PARTITION BY Region ORDER BY `Happiness Score`) `Unhappiness Rank`
	FROM `2015_report_1`
	GROUP BY Country, Region, `Happiness Score`
)
SELECT *
FROM Regional_Rank
WHERE `Unhappiness Rank` BETWEEN 1 AND 5;

DELIMITER $$
CREATE PROCEDURE Happiest_Country_Per_Region(IN p_region varchar(50))
BEGIN
	WITH Regional_Rank AS (
		SELECT Country, Region, `Happiness Score`,
		RANK() OVER(PARTITION BY Region ORDER BY `Happiness Score` DESC) `Rank Per Region`,
        `Happiness Rank` as `Global Happiness Rank`
		FROM `2015_report_1`
		GROUP BY Country, Region, `Happiness Score`, `Happiness Rank`
	)
	SELECT Country, Region, `Happiness Score`, `Global Happiness Rank`
	FROM Regional_Rank
	WHERE `Rank Per Region` = 1 AND Region = p_region;
END $$
DELIMITER ;

SELECT * 
FROM `2015_report_1`;

CALL Happiest_Country_Per_Region('Australia and New Zealand');
CALL Happiest_Country_Per_Region('Sub-Saharan Africa');
CALL Happiest_Country_Per_Region('Middle East and Northern Africa');
CALL Happiest_Country_Per_Region('North America');
CALL Happiest_Country_Per_Region('Western Europe');

DELIMITER $$
CREATE PROCEDURE Top_5_Happiest_Per_Region(IN p_region varchar(50))
BEGIN
	WITH Regional_Rank AS (
		SELECT Country, Region, `Happiness Score`,
		RANK() OVER(PARTITION BY Region ORDER BY `Happiness Score` DESC) `Rank Per Region`,
        `Happiness Rank` as `Global Happiness Rank`
		FROM `2015_report_1`
		GROUP BY Country, Region, `Happiness Score`, `Happiness Rank`
	)
	SELECT Country, Region, `Happiness Score`, `Global Happiness Rank`
	FROM Regional_Rank
	WHERE Region = p_region AND `Rank Per Region` BETWEEN 1 AND 5;
END $$
DELIMITER ;

CALL Top_5_Happiest_Per_Region('Australia and New Zealand');
CALL Top_5_Happiest_Per_Region('Sub-Saharan Africa');
CALL Top_5_Happiest_Per_Region('Middle East and Northern Africa');
CALL Top_5_Happiest_Per_Region('North America');
CALL Top_5_Happiest_Per_Region('Western Europe');
CALL Top_5_Happiest_Per_Region('Latin America and Caribbean');


DELIMITER $$
CREATE PROCEDURE Saddest_Country_Per_Region(IN p_region varchar(50))
BEGIN
	WITH Regional_Rank AS (
		SELECT Country, Region, `Happiness Score`,
		RANK() OVER(PARTITION BY Region ORDER BY `Happiness Score`) `Sadness Rank Per Region`,
        `Happiness Rank` as `Global Happiness Rank`
		FROM `2015_report_1`
		GROUP BY Country, Region, `Happiness Score`, `Happiness Rank`
	)
	SELECT Country, Region, `Happiness Score`, `Global Happiness Rank`
	FROM Regional_Rank
	WHERE `Sadness Rank Per Region` = 1 AND Region = p_region;
END $$
DELIMITER ;


CALL Saddest_Country_Per_Region('Australia and New Zealand');
CALL Saddest_Country_Per_Region('Sub-Saharan Africa');
CALL Saddest_Country_Per_Region('Middle East and Northern Africa');
CALL Saddest_Country_Per_Region('North America');
CALL Saddest_Country_Per_Region('Western Europe');


DELIMITER $$
CREATE PROCEDURE Top_5_Saddest_Per_Region(IN p_region varchar(50))
BEGIN
	WITH Regional_Rank AS (
		SELECT Country, Region, `Happiness Score`,
		RANK() OVER(PARTITION BY Region ORDER BY `Happiness Score`) `Sadness Rank Per Region`,
        `Happiness Rank` as `Global Happiness Rank`
		FROM `2015_report_1`
		GROUP BY Country, Region, `Happiness Score`, `Happiness Rank`
	)
	SELECT Country, Region, `Happiness Score`, `Global Happiness Rank`
	FROM Regional_Rank
	WHERE Region = p_region AND `Sadness Rank Per Region` BETWEEN 1 AND 5;
END $$
DELIMITER ;


CALL Top_5_Saddest_Per_Region('Australia and New Zealand');
CALL Top_5_Saddest_Per_Region('Sub-Saharan Africa');
CALL Top_5_Saddest_Per_Region('Middle East and Northern Africa');
CALL Top_5_Saddest_Per_Region('North America');
CALL Top_5_Saddest_Per_Region('Western Europe');
CALL Top_5_Saddest_Per_Region('Latin America and Caribbean');

SELECT * 
FROM `2015_report_1`;


-- How Govt Corruption affects Happiness per country
WITH Regional_Rank AS (
	SELECT Country, Region, `Happiness Score`,
	RANK() OVER(PARTITION BY Region ORDER BY `Happiness Score`) `Rank Per Region`,
    `Trust (Government Corruption)`
	FROM `2015_report_1`
	GROUP BY Country, Region, `Happiness Score`, `Trust (Government Corruption)` 
)
SELECT *
FROM Regional_Rank
WHERE `Rank Per Region` BETWEEN 1 AND 5;

-- How Govt Corruption affects Happiness per region
SELECT Region, ROUND(AVG(`Happiness Score`), 2) `Average Happiness Score`, 
ROUND(AVG(`Trust (Government Corruption)`), 2) `Average Corruption Rate`,
RANK() OVER(ORDER BY AVG(`Happiness Score`) DESC) `Happiness Rank`
FROM `2015_report_1`
GROUP BY Region
ORDER BY `Average Corruption Rate` DESC;

-- How Freedom affects Happiness per region
SELECT Region, ROUND(AVG(`Happiness Score`), 2) `Average Happiness Score`, 
ROUND(AVG(`Freedom`), 2) `Average Freedom Rate`,
RANK() OVER(ORDER BY AVG(`Happiness Score`) DESC) `Happiness Rank`
FROM `2015_report_1`
GROUP BY Region
ORDER BY `Average Freedom Rate` DESC;

SELECT * 
FROM `2015_report_1`;

-- How Economy affects Happiness per region
SELECT Region, ROUND(AVG(`Happiness Score`), 2) `Average Happiness Score`, 
ROUND(AVG(`Economy (GDP per Capita)`), 2) `Average Economy Rate`,
ROUND(AVG(`Trust (Government Corruption)`), 2) `Average Corruption Rate`,
RANK() OVER(ORDER BY AVG(`Happiness Score`) DESC) `Happiness Rank`
FROM `2015_report_1`
GROUP BY Region
ORDER BY `Average Economy Rate` DESC;

-- How Happiness correlates to Health (Life Expectancy) per region
SELECT Region, ROUND(AVG(`Happiness Score`), 2) `Average Happiness Score`, 
ROUND(AVG(`Health (Life Expectancy)`), 2) `Average Life Expectancy`,
RANK() OVER(ORDER BY AVG(`Happiness Score`) DESC) `Happiness Rank`
FROM `2015_report_1`
GROUP BY Region
ORDER BY `Average Life Expectancy` DESC;


-- 2016 REPORT
SELECT *
FROM `2016_report`;

-- Staging Table
CREATE TABLE `2016_report_1`
SELECT *
FROM `2016_report`;


-- Seeing trends between 2015 and 2016
SELECT `2015_report_1`.Country, `2015_report_1`.`Happiness Rank` `2015 Happiness Rank`,
`2016_report_1`.`Happiness Rank` `2016 Happiness Rank`
FROM `2015_report_1` 
JOIN `2016_report_1` ON
	`2015_report_1`.Country = `2016_report_1`.Country; 

-- Countries that are in 2015 report but not in 2016 report
SELECT `2015_report_1`.Country
FROM `2015_report_1` 
LEFT JOIN `2016_report_1` ON
	`2015_report_1`.Country = `2016_report_1`.Country
WHERE `2015_report_1`.Country IS NOT NULL AND `2016_report_1`.Country  IS NULL;

-- Countries that are in 2016 report but not in 2015 report
SELECT `2016_report_1`.Country
FROM `2015_report_1` 
RIGHT JOIN `2016_report_1` ON
	`2015_report_1`.Country = `2016_report_1`.Country
WHERE `2016_report_1`.Country IS NOT NULL AND `2015_report_1`.Country  IS NULL;

-- Difference between happiness ranks to see which country drastically reduced on increased happiness ranks
WITH yearly_analysis AS (
	SELECT `2015_report_1`.Country, 
	`2015_report_1`.`Happiness Rank` `2015 Happiness Rank`,
	`2015_report_1`.`Happiness Score` `2015 Happiness Score`,
	`2016_report_1`.`Happiness Rank` `2016 Happiness Rank`,
	`2016_report_1`.`Happiness Score` `2016 Happiness Score`,
    (
		`2016_report_1`.`Happiness Rank` - `2015_report_1`.`Happiness Rank`
    ) as `Rank Difference`,
    (
		`2016_report_1`.`Happiness Score` - `2015_report_1`.`Happiness Score`
    ) as `Score Difference`
	FROM `2015_report_1` 
	JOIN `2016_report_1` ON
		`2015_report_1`.Country = `2016_report_1`.Country
)
SELECT *,
CASE 
	WHEN `Rank Difference` < 0 THEN 'Increased Happiness Rank'
    WHEN `Rank Difference` = 0 THEN 'Same as Previous Year'
    ELSE 'Reduced Happiness Rank'
END AS `Rank Category`,
CASE
	WHEN `Score Difference` < 0 THEN 'Decreased Happiness Score'
    WHEN `Score Difference` = 0 THEN 'Same Happiness Score'
    ELSE 'Increased Happiness Score'
END AS `Score category`
FROM yearly_analysis;

-- Comparing average happiness rank per region per year
WITH Regional_Analysis AS (
	SELECT `2015_report_1`.Region, 
	ROUND(AVG(`2015_report_1`.`Happiness Score`), 2) `2015 Average Happiness Score`, 
    RANK() OVER(ORDER BY AVG(`2015_report_1`.`Happiness Score`) DESC) `2015 Average Happiness Rank`,
	ROUND(AVG(`2016_report_1`.`Happiness Score`), 2) `2016 Average Happiness Score`,
    RANK() OVER(ORDER BY AVG(`2016_report_1`.`Happiness Score`) DESC) `2016 Average Happiness Rank`
	FROM `2015_report_1`
	JOIN `2016_report_1` ON
		`2015_report_1`.Country = `2016_report_1`.Country
	GROUP BY Region
)
SELECT *, 
(
	ROUND(`2016 Average Happiness Score` - `2015 Average Happiness Score`, 2)
) AS `Score Difference`,
CASE 
	WHEN `2016 Average Happiness Score` < `2015 Average Happiness Score` THEN 'Reduced Happiness Score'
    WHEN `2016 Average Happiness Score` > `2015 Average Happiness Score` THEN 'Increased Happiness Score'
    ELSE 'Same Happiness Score'
END AS 'Score Category',
CASE 
	WHEN `2016 Average Happiness Rank` < `2015 Average Happiness Rank` THEN 'Reduced Happiness Rank'
    WHEN `2016 Average Happiness Rank` > `2015 Average Happiness Rank` THEN 'Increased Happiness Rank'
    ELSE 'Same Happiness Rank'
END AS 'Score Category'
FROM Regional_Analysis
ORDER BY `2015 Average Happiness Rank`;

-- Which factor (Economy, Family, Health, Freedom, Generosity, Trust) 
-- contributes the most to happiness on average globally in 2015?
SELECT * 
FROM `2015_report_1`;

SELECT ROUND(AVG(`Economy (GDP per Capita)`), 2) `Average Economy`, 
ROUND(AVG(`Family`), 2) `Average Family Factor`,
ROUND(AVG(`Health (Life Expectancy)`), 2) `Average Health Factor`,
ROUND(AVG(`Freedom`), 2) `Average Freedom Factor`,
ROUND(AVG(`Trust (Government Corruption)`), 2) `Average Trust Factor`,
ROUND(AVG(`Generosity`), 2) `Average Generosity Factor`
FROM `2015_report_1`;

-- Which countries had the biggest improvement in happiness score from 2015 to 2016 — top 10?
WITH Happiness_Improvement AS (
	SELECT `2015_report_1`.Country, 
	`2015_report_1`.`Happiness Score` `2015 Happiness Score`, 
	`2016_report_1`.`Happiness Score` `2016 Happiness Score`,
	ROUND(`2016_report_1`.`Happiness Score` - `2015_report_1`.`Happiness Score`, 2) as `Score Difference`
	FROM `2015_report_1`
	JOIN `2016_report_1` ON
		`2015_report_1`.Country = `2016_report_1`.Country
) 
SELECT *
FROM Happiness_Improvement
ORDER BY `Score Difference` DESC
LIMIT 10;

WITH Happiness_Improvement AS (
	SELECT `2015_report_1`.Country, 
	`2015_report_1`.`Happiness Score` `2015 Happiness Score`, 
	`2016_report_1`.`Happiness Score` `2016 Happiness Score`,
	ROUND(`2016_report_1`.`Happiness Score` - `2015_report_1`.`Happiness Score`, 2) as `Score Difference`
	FROM `2015_report_1`
	JOIN `2016_report_1` ON
		`2015_report_1`.Country = `2016_report_1`.Country
) 
SELECT *
FROM Happiness_Improvement
ORDER BY `Score Difference`
LIMIT 10;

SELECT * 
FROM `2015_report_1`
WHERE Country = 'Liberia';

SELECT * 
FROM `2015_report_1`
ORDER BY `Health (Life Expectancy)`;

-- Which region is the most generous and does generosity correlate with happiness?
SELECT 
    `2015_report_1`.Region,
    ROUND(AVG(`2015_report_1`.Generosity), 2) `2015 Average Generosity`,
    ROUND(AVG(`2016_report_1`.Generosity), 2) `2016 Average Generosity`,
    ROUND(
		AVG(`2015_report_1`.Generosity)- AVG(`2016_report_1`.Generosity), 2
    ) AS `Generosity Difference`,
    ROUND(AVG(`2015_report_1`.`Happiness Score`),
            2) `2015 Average Happiness Score`,
    ROUND(AVG(`2016_report_1`.`Happiness Score`),
            2) `2016 Average Happiness Score`
FROM `2015_report_1`
	JOIN `2016_report_1` ON
		`2015_report_1`.Country = `2016_report_1`.Country
GROUP BY Region
ORDER BY `2015 Average Generosity` DESC

-- Country Profile
DELIMITER $$
CREATE PROCEDURE Get_Country_Profile(IN p_country varchar(50))
BEGIN
	SELECT `2015_report_1`.Country, `2015_report_1`.Region,
    `2015_report_1`.`Happiness Score` `2015 Happiness Score`,
    `2015_report_1`.`Happiness Rank` `2015 Happiness Rank`,
    `2016_report_1`.`Happiness Score` `2016 Happiness Score`,
    `2016_report_1`.`Happiness Rank` `2016 Happiness Rank`,
    ROUND(`2016_report_1`.`Happiness Score` - `2015_report_1`.`Happiness Score`, 2) `Score Difference`,
    ROUND(`2016_report_1`.`Happiness Rank` - `2015_report_1`.`Happiness Rank`, 2) `Rank Difference`,
	`2015_report_1`.`Economy (GDP per Capita)` `2015 Economic Factor`,
    `2015_report_1`.`Family` `2015 Family Factor`,
    `2015_report_1`.`Health (Life Expectancy)` `2015 Health Factor`,
    `2015_report_1`.`Freedom` `2015 Freedom Factor`,
    `2015_report_1`.`Trust (Government Corruption)` `2015 Trust Factor`,
    `2015_report_1`.`Generosity` `2015 Generosity Factor`
    FROM `2015_report_1`
    JOIN `2016_report_1` ON
		`2015_report_1`.Country = `2016_report_1`.Country
	WHERE `2015_report_1`.Country = p_country;
END $$
DELIMITER ;

CALL Get_Country_Profile('Finland');
CALL Get_Country_Profile('Nigeria');
CALL Get_Country_Profile('United States');

-- "Which countries consistently rank in the top 10 across both 2015 and 2016?"
SELECT `2015_report_1`.Country, `2015_report_1`.Region, 
`2015_report_1`.`Happiness Rank` `2015 Happiness Rank`,
`2016_report_1`.`Happiness Rank` `2016 Happiness Rank`,
(
	(`2016_report_1`.`Happiness Rank` + `2015_report_1`.`Happiness Rank`)/2
) `Average Rank between years`
FROM `2015_report_1`
JOIN `2016_report_1` ON
	`2015_report_1`.Country = `2016_report_1`.Country
WHERE `2015_report_1`.`Happiness Rank` <= 10 AND `2016_report_1`.`Happiness Rank` <= 10;


CREATE TEMPORARY TABLE happiness_analysis
SELECT `2015_report_1`.Country, `2015_report_1`.Region, 
`2015_report_1`.`Happiness Score` `2015 Happiness Score`,
`2015_report_1`.`Happiness Rank` `2015 Happiness Rank`,
`2016_report_1`.`Happiness Score` `2016 Happiness Score`,
`2016_report_1`.`Happiness Rank` `2016 Happiness Rank`,
(
	`2016_report_1`.`Happiness Score`  - `2015_report_1`.`Happiness Score` 
) AS `Score Difference`,
(
	`2016_report_1`.`Happiness Rank`  - `2015_report_1`.`Happiness Rank` 
) AS `Rank Difference`,
`2015_report_1`.`Economy (GDP per Capita)`,
`2015_report_1`.`Family`,
`2015_report_1`.`Health (Life Expectancy)`,
`2015_report_1`.`Freedom`,
`2015_report_1`.`Trust (Government Corruption)`,
`2015_report_1`.`Generosity`,
CASE GREATEST(`2015_report_1`.`Economy (GDP per Capita)`, 
`2015_report_1`.`Family`, 
`2015_report_1`.`Health (Life Expectancy)`, 
`2015_report_1`.`Freedom`, 
`2015_report_1`.`Trust (Government Corruption)`, 
`2015_report_1`.`Generosity`)
    WHEN `2015_report_1`.`Economy (GDP per Capita)` THEN 'Economy'
    WHEN `2015_report_1`.`Family` THEN 'Family'
    WHEN `2015_report_1`.`Health (Life Expectancy)` THEN 'Health'
    WHEN `2015_report_1`.`Freedom` THEN 'Freedom'
    WHEN `2015_report_1`.`Trust (Government Corruption)` THEN 'Trust'
    WHEN `2015_report_1`.`Generosity` THEN 'Generosity'
END AS `Dominant Factor`,
CASE
	WHEN `2016_report_1`.`Happiness Score` > `2015_report_1`.`Happiness Score` THEN 'Improving'
    WHEN `2016_report_1`.`Happiness Score` < `2015_report_1`.`Happiness Score` THEN 'Declining'
    ELSE 'Stable'
END AS 	`Trend Label`
FROM `2015_report_1`
JOIN `2016_report_1` ON
	`2015_report_1`.Country = `2016_report_1`.Country;

-- Most common dominant factor per region
WITH Factor_Count AS (
	SELECT Region, `Dominant Factor`, COUNT(`Dominant Factor`) `Factor Count`,
    RANK() OVER(PARTITION BY Region ORDER BY COUNT(`Dominant Factor`) DESC) `Factor Rank`
	FROM happiness_analysis
	GROUP BY Region, `Dominant Factor`
)
SELECT Region, `Dominant Factor`
FROM Factor_Count
WHERE `Factor Rank` = 1;


SELECT * FROM happiness_analysis;
-- Average score difference per trend category
SELECT `Trend Label`, ROUND(AVG(`Score Difference`), 2)
FROM happiness_analysis
GROUP BY `Trend Label`;

-- Top 5 most improved countries per region
WITH Country_Rank AS (
	SELECT Region, Country,
    RANK() OVER(PARTITION BY Region ORDER BY `Score Difference` DESC) `Improvement Rank`
    FROM happiness_analysis
)
SELECT * 
FROM Country_Rank
WHERE `Improvement Rank` <= 5;




