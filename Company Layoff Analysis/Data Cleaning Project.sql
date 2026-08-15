-- Data Cleaning

SELECT *
FROM layoffs; 

-- 1. Remove Duplicates
-- 2. Standardize the Data - spelling errors etc
-- 3. NULL Values or blank values
-- 4. Remove Any Redundant Columns or Rows


-- Creating a staging table so we do not directly edit the raw table
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging; 

INSERT layoffs_staging 
SELECT *
FROM layoffs;

-- 1. REMOVING DUPLICATES
-- By matching a row number to each row

SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) row_num
FROM layoffs_staging;

-- Checking for duplicates 
WITH duplicate_cte AS (
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off,
    percentage_laid_off, `date`, stage, country, funds_raised_millions) row_num
	FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte 
WHERE row_num > 1;
-- Checking duplicate company
SELECT * 
FROM layoffs_staging 
WHERE company = 'Casper';

-- To delete duplicates here, we need to create another staging table/db
-- that has row_num in it, so we can filter them out based on the row_num

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
	ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off,
	percentage_laid_off, `date`, stage, country, funds_raised_millions) row_num
FROM layoffs_staging;

-- Deleting duplicates i.e.  when row_num is greater than 1
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- 2. STANDARDIZING DATA

-- Removing white spaces
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Generalizing all Crypto, CryptoCurrency 
-- and Crypto Currency industries to Just Crypto
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Removing . from the end of countries
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE country LIKE '%.';

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Converting the text column to the date type
SELECT `date`
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- 3. HANDLING NULL VALUES
-- Populating industries that are blank
-- REMOVE DUPLICATES AGAIN
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num) row_num2
FROM layoffs_staging2;

CREATE TABLE `layoffs_staging3` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT,
  `row_num2` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging3;

INSERT INTO layoffs_staging3
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num) row_num2
FROM layoffs_staging2;

DELETE
FROM layoffs_staging3
WHERE row_num2 > 1;

SELECT *
FROM layoffs_staging3
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging3
WHERE company = 'Airbnb';

UPDATE layoffs_staging3  
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging3 t1
JOIN layoffs_staging3 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


UPDATE layoffs_staging3 t1
JOIN layoffs_staging3 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging3;

-- 4. REMOVE REDUNDANT COLUMNS OR ROWS
SELECT *
FROM layoffs_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging3;

ALTER TABLE layoffs_staging3
DROP COLUMN row_num2;

ALTER TABLE layoffs_staging3
DROP COLUMN row_num;


