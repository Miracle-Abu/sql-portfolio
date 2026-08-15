DROP TABLE IF EXISTS nashville_housing;

CREATE TABLE nashville_housing (
    blank_col TEXT,
    unnamed_index TEXT,
    parcel_id TEXT,
    land_use TEXT,
    property_address TEXT,
    suite_condo TEXT,
    property_city TEXT,
    sale_date TEXT,
    sale_price TEXT,
    legal_reference TEXT,
    sold_as_vacant TEXT,
    multiple_parcels TEXT,
    owner_name TEXT,
    owner_address TEXT,
    owner_city TEXT,
    owner_state TEXT,
    acreage TEXT,
    tax_district TEXT,
    neighborhood TEXT,
    image TEXT,
    land_value TEXT,
    building_value TEXT,
    total_value TEXT,
    finished_area TEXT,
    foundation_type TEXT,
    year_built TEXT,
    exterior_wall TEXT,
    grade TEXT,
    bedrooms TEXT,
    full_bath TEXT,
    half_bath TEXT
);

SELECT * FROM nashville_housing;

LOAD DATA INFILE '/var/lib/mysql-files/Nashville_housing_data_2013_2016.csv'
INTO TABLE nashville_housing
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM nashville_housing;

SELECT * FROM nashville_housing LIMIT 10;

-- CREATE STAGING TABLE
CREATE TABLE nashville_housing_1
SELECT *
FROM nashville_housing;

SELECT *
FROM nashville_housing_1;

-- DATA CLEANING
-- Remove Redundant Columns

ALTER TABLE nashville_housing_1
	DROP COLUMN blank_col,
    DROP COLUMN unnamed_index,
    DROP COLUMN image;
    
SELECT *
FROM nashville_housing_1 
LIMIT 5;

-- Removing Duplicates
WITH Nashville_CTE AS (
	SELECT *, 
    ROW_NUMBER() OVER(PARTITION BY parcel_id, property_address, sale_date, sale_price, legal_reference) row_num
    FROM nashville_housing_1
)
SELECT * 
FROM Nashville_CTE
WHERE row_num > 1;

-- Create nashville_housing_2
CREATE TABLE nashville_housing_2 (
    blank_col TEXT,
    unnamed_index TEXT,
    parcel_id TEXT,
    land_use TEXT,
    property_address TEXT,
    suite_condo TEXT,
    property_city TEXT,
    sale_date TEXT,
    sale_price TEXT,
    legal_reference TEXT,
    sold_as_vacant TEXT,
    multiple_parcels TEXT,
    owner_name TEXT,
    owner_address TEXT,
    owner_city TEXT,
    owner_state TEXT,
    acreage TEXT,
    tax_district TEXT,
    neighborhood TEXT,
    image TEXT,
    land_value TEXT,
    building_value TEXT,
    total_value TEXT,
    finished_area TEXT,
    foundation_type TEXT,
    year_built TEXT,
    exterior_wall TEXT,
    grade TEXT,
    bedrooms TEXT,
    full_bath TEXT,
    half_bath TEXT,
    row_num INT
);

SELECT * 
FROM nashville_housing_2;

-- drop columns
ALTER TABLE nashville_housing_2
	DROP COLUMN blank_col,
    DROP COLUMN unnamed_index,
    DROP COLUMN image;

INSERT INTO nashville_housing_2
SELECT *, 
    ROW_NUMBER() OVER(PARTITION BY parcel_id, property_address, sale_date, sale_price, legal_reference) row_num
FROM nashville_housing_1;

DELETE 
FROM nashville_housing_2
WHERE row_num > 1;

SELECT * 
FROM nashville_housing_2
WHERE row_num > 1; -- Empty


SELECT * 
FROM nashville_housing_2;
-- STANDARDIZING THE DATA
-- Triming Whitespaces
SELECT property_address, TRIM(property_address)
FROM nashville_housing_2
WHERE property_address != TRIM(property_address);

UPDATE nashville_housing_2
SET property_address = TRIM(property_address)
WHERE property_address != TRIM(property_address);


UPDATE nashville_housing_2
SET
	parcel_id = TRIM(parcel_id),
    land_use = TRIM(land_use),
    property_address = TRIM(property_address),
    suite_condo = TRIM(suite_condo),
    property_city = TRIM(property_city),
    sold_as_vacant = TRIM(sold_as_vacant),
    owner_name = TRIM(owner_name),
    owner_address = TRIM(owner_address),
    owner_city = TRIM(owner_city),
    owner_state = TRIM(owner_state),
    tax_district = TRIM(tax_district),
    grade = TRIM(grade),
    foundation_type = TRIM(foundation_type),
    exterior_wall = TRIM(exterior_wall);

SELECT sold_as_vacant, COUNT(*) count
FROM nashville_housing_2
GROUP BY sold_as_vacant
ORDER BY count DESC;

-- Errors in Land Use Column
SELECT DISTINCT land_use
FROM nashville_housing_2
ORDER BY land_use;

SELECT * 
FROM nashville_housing_2
WHERE land_use LIKE '%greenbelt%' OR '%grrenbelt%';

-- Check what it looks like
SELECT land_use, LENGTH(land_use)
FROM nashville_housing_2
WHERE land_use LIKE '%GREENBELT%';

-- Fix by taking only the first value before the newline
UPDATE nashville_housing_2
SET land_use = SUBSTRING_INDEX(land_use, '\n', 1)
WHERE land_use LIKE '%\n%';

-- Check for hidden characters in GREENBELT rows
SELECT land_use, LENGTH(land_use), HEX(land_use)
FROM nashville_housing_2
WHERE land_use LIKE '%GREENBELT%'
LIMIT 5;

-- Fix carriage returns in land_use
UPDATE nashville_housing_2
SET land_use = TRIM(TRAILING '\r' FROM land_use)
WHERE land_use LIKE '%\r%';

UPDATE nashville_housing_2
SET land_use = 'VACANT RESIDENTIAL LAND'
WHERE land_use LIKE '%VACANT RES%';


-- Converting Sale Date
SELECT sale_date 
FROM nashville_housing_2
LIMIT 100;

UPDATE nashville_housing_2
SET sale_date = STR_TO_DATE(sale_date, '%Y-%m-%d');

ALTER TABLE nashville_housing_2
MODIFY COLUMN sale_date DATE;

-- Modifying types
SELECT *
FROM nashville_housing_2;

-- SET empty values to null
UPDATE nashville_housing_2
SET 
    sale_price = NULLIF(sale_price, ''),
    acreage = NULLIF(acreage, ''),
    land_value = NULLIF(land_value, ''),
    building_value = NULLIF(building_value, ''),
    total_value = NULLIF(total_value, ''),
    finished_area = NULLIF(finished_area, ''),
    year_built = NULLIF(year_built, ''),
    bedrooms = NULLIF(bedrooms, ''),
    full_bath = NULLIF(full_bath, ''),
    half_bath = NULLIF(half_bath, ''),
    suite_condo = NULLIF(suite_condo, '');

ALTER TABLE nashville_housing_2
MODIFY COLUMN sale_price INT,
MODIFY COLUMN acreage DECIMAL(10,2),
MODIFY COLUMN land_value INT,
MODIFY COLUMN building_value INT,
MODIFY COLUMN total_value INT,
MODIFY COLUMN finished_area INT,
MODIFY COLUMN year_built INT,
MODIFY COLUMN bedrooms INT,
MODIFY COLUMN full_bath INT,
MODIFY COLUMN half_bath INT;

UPDATE nashville_housing_2
SET 
    owner_name = NULLIF(owner_name, ''),
    owner_address = NULLIF(owner_address, ''),
    owner_city = NULLIF(owner_city, ''),
    owner_state = NULLIF(owner_state, ''),
    tax_district = NULLIF(tax_district, ''),
    neighborhood = NULLIF(neighborhood, ''),
    foundation_type = NULLIF(foundation_type, ''),
    exterior_wall = NULLIF(exterior_wall, ''),
    property_address = NULLIF(property_address, ''),
    property_city = NULLIF(property_city, ''),
    land_use = NULLIF(land_use, ''),
    grade = NULLIF(grade, ''),
    multiple_parcels = NULLIF(multiple_parcels, '');
    
    
-- To check the amount of nulls in each column
SELECT 
    SUM(CASE WHEN property_address IS NULL THEN 1 ELSE 0 END) property_address_nulls,
    SUM(CASE WHEN owner_name IS NULL THEN 1 ELSE 0 END) owner_name_nulls,
    SUM(CASE WHEN owner_address IS NULL THEN 1 ELSE 0 END) owner_address_nulls,
    SUM(CASE WHEN owner_city IS NULL THEN 1 ELSE 0 END) owner_city_nulls,
    SUM(CASE WHEN tax_district IS NULL THEN 1 ELSE 0 END) tax_district_nulls,
    SUM(CASE WHEN neighborhood IS NULL THEN 1 ELSE 0 END) neighborhood_nulls,
    SUM(CASE WHEN foundation_type IS NULL THEN 1 ELSE 0 END) foundation_type_nulls,
    SUM(CASE WHEN exterior_wall IS NULL THEN 1 ELSE 0 END) exterior_wall_nulls,
    SUM(CASE WHEN sale_price IS NULL THEN 1 ELSE 0 END) sale_price_nulls,
    SUM(CASE WHEN year_built IS NULL THEN 1 ELSE 0 END) year_built_nulls,
    SUM(CASE WHEN bedrooms IS NULL THEN 1 ELSE 0 END) bedroom_nulls
FROM nashville_housing_2;

-- FILLING NULLS
SELECT t1.parcel_id, t1.property_address, t2.parcel_id, t2.property_address
FROM nashville_housing_2 t1
JOIN nashville_housing_2 t2
	ON t1.parcel_id = t2.parcel_id
WHERE t1.property_address IS NULL 
	AND t2.property_address IS NOT NULL;
    
UPDATE nashville_housing_2 t1
JOIN nashville_housing_2 t2
	ON t1.parcel_id = t2.parcel_id
SET t1.property_address = t2.property_address
WHERE t1.property_address IS NULL 
	AND t2.property_address IS NOT NULL;

-- Property City
SELECT *
FROM nashville_housing_2;

SELECT t1.parcel_id, t1.property_city, t2.parcel_id, t2.property_city
FROM nashville_housing_2 t1
JOIN nashville_housing_2 t2
	ON t1.parcel_id = t2.parcel_id
WHERE t1.property_city IS NULL 
	AND t2.property_city IS NOT NULL;
    
UPDATE nashville_housing_2 t1
JOIN nashville_housing_2 t2
	ON t1.parcel_id = t2.parcel_id
SET t1.property_city = t2.property_city
WHERE t1.property_city IS NULL 
	AND t2.property_city IS NOT NULL;
    

SELECT property_address
FROM nashville_housing_2
LIMIT 10;

SELECT owner_address
FROM nashville_housing_2
WHERE owner_address IS NOT NULL
LIMIT 10;


-- Remove Redundant columns
SELECT * 
FROM nashville_housing_2 
WHERE suite_condo IS NOT NULL;

SELECT DISTINCT owner_state
FROM nashville_housing_2;

ALTER TABLE nashville_housing_2
	DROP COLUMN row_num,
    DROP COLUMN owner_state;
    
SELECT * FROM nashville_housing_2 LIMIT 10;

