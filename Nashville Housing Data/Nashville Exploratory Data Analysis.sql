-- Nashville Housing Data Exploratory Data Analysis

SELECT * 
FROM nashville_housing_2
WHERE property_city IS NULL
LIMIT 10;

-- What is the total number of sales, average sale price, minimum sale price and maximum sale price across the entire dataset?
SELECT COUNT(*) number_of_sales, ROUND(AVG(sale_price), 2) avg_sale_price, MIN(sale_price) min_sale_price, MAX(sale_price) max_sale_price
FROM nashville_housing_2;

-- How did total sales count and average sale price change year over year?
WITH Nashville_Yearly AS (
	SELECT YEAR(sale_date) `year`, COUNT(*) total_sales, ROUND(AVG(sale_price), 2) average_sales
	FROM nashville_housing_2 
	GROUP BY `year`
	ORDER BY `year`
)
SELECT *,
(average_sales - LAG(average_sales, 1, 0) OVER(ORDER BY `year`)) yoy_average_price 
FROM Nashville_Yearly;


-- Which property types (land use) have the highest average sale price and total number of sales?
SELECT land_use, COUNT(land_use) total_sale_count, ROUND(AVG(sale_price), 2) avg_sale_price, SUM(sale_price) total_revenue
FROM nashville_housing_2
WHERE sale_price IS NOT NULL AND land_use IS NOT NULL
GROUP BY land_use
ORDER BY avg_sale_price DESC;

-- Which cities have the highest average sale price and total number of sales
SELECT property_city, COUNT(*) total_sale_count, ROUND(AVG(sale_price), 2) avg_sale_price, 
MIN(sale_price) min_sale_price, MAX(sale_price) max_sale_price
FROM nashville_housing_2
WHERE sale_price IS NOT NULL AND property_city IS NOT NULL
GROUP BY property_city
ORDER BY avg_sale_price DESC
LIMIT 15;


-- Sold as vacant vs Not Vacant
SELECT 
    sold_as_vacant,
    COUNT(*) `count`,
    (ROUND((COUNT(*) / (SELECT 
                    COUNT(*)
                FROM
                    nashville_housing_2)) * 100,
            2)) AS percentage,
    ROUND(AVG(sale_price), 2) avg_sale_price
FROM
    nashville_housing_2
GROUP BY sold_as_vacant
ORDER BY `count` DESC;


-- What is the relationship between land value, building value and total value per property type?
SELECT 
    land_use,
    ROUND(AVG(land_value), 2) avg_land_value,
    ROUND(AVG(building_value), 2) avg_building_value,
    ROUND(AVG(total_value), 2) avg_total_value,
    ROUND(AVG(building_value / total_value) * 100, 2) ratio
FROM nashville_housing_2
WHERE land_value IS NOT NULL
AND building_value IS NOT NULL
AND total_value IS NOT NULL
GROUP BY land_use
ORDER BY avg_total_value DESC;


-- How does the number of bedrooms affect the average sale price?
SELECT * FROM nashville_housing_2;

SELECT bedrooms, COUNT(*) property_count, ROUND(AVG(sale_price), 2) avg_price
FROM nashville_housing_2
WHERE bedrooms IS NOT NULL 
AND bedrooms !=  0
GROUP BY bedrooms
ORDER BY bedrooms;


-- What are the top 10 most expensive and top 10 least expensive property sales, showing the full details?
SELECT property_address, property_city, land_use, sale_date, sale_price, bedrooms, total_value
FROM nashville_housing_2
WHERE sale_price IS NOT NULL
ORDER BY sale_price DESC
LIMIT 10;

SELECT property_address, property_city, land_use, sale_date, sale_price, bedrooms, total_value
FROM nashville_housing_2
WHERE sale_price IS NOT NULL
ORDER BY sale_price
LIMIT 10;



