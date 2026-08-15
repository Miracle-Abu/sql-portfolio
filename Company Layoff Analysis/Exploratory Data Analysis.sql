-- Exploratory Data Analysis

SELECT * 
FROM layoffs_staging3;

SELECT *
FROM layoffs_staging3
WHERE total_laid_off = (SELECT MAX(total_laid_off) FROM layoffs_staging3);

SELECT *
FROM layoffs_staging3
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY company
ORDER BY 2 DESC;

SELECT *
FROM layoffs_staging3
WHERE company LIKE '%Amazon%';

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging3;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY industry
ORDER BY 2 DESC;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY YEAR(`date`)
ORDER BY 1;

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY stage
ORDER BY 2 DESC;

SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) total_off
FROM layoffs_staging3
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1;

WITH Rolling_Total AS 
(
	SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) total_off
	FROM layoffs_staging3
	WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
	GROUP BY `MONTH`
	ORDER BY 1
)
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) rolling_total
FROM Rolling_Total;

-- How much companies are laying off per year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY company,  YEAR(`date`);

-- Company Layoff Ranking Per Year
WITH Company_Year (company, years, total_laid_off) AS (
	SELECT company, YEAR(`date`), SUM(total_laid_off)
	FROM layoffs_staging3
	GROUP BY company,  YEAR(`date`)
), Company_Year_Rank AS (
	SELECT *,
	DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) ranking
	FROM Company_Year
	WHERE years IS NOT NULL
)
SELECT * 
FROM Company_Year_Rank
WHERE ranking <= 5;


-- Industry Layoffs Ranking Per Year
WITH Industry_Year (industry, years, total_laid_off) AS (
	SELECT industry, YEAR(`date`), SUM(total_laid_off)
	FROM layoffs_staging3
	GROUP BY industry,  YEAR(`date`)
), Industry_Year_Rank AS (
	SELECT *,
	DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) ranking
	FROM Industry_Year
	WHERE years IS NOT NULL
)
SELECT * 
FROM Industry_Year_Rank
WHERE ranking <= 5;


-- Country Layoffs Ranking Per Year
WITH Country_Year (country, years, total_laid_off) AS (
	SELECT country, YEAR(`date`), SUM(total_laid_off)
	FROM layoffs_staging3
	GROUP BY country,  YEAR(`date`)
), Country_Year_Rank AS (
	SELECT *,
	DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) ranking
	FROM Country_Year
	WHERE years IS NOT NULL
)
SELECT * 
FROM Country_Year_Rank
WHERE ranking <= 5;

SELECT *
FROM layoffs_staging3;


-- MORE EDA
-- Do companies that raised more money lay off more people?
SELECT company, funds_raised_millions, total_laid_off, percentage_laid_off
FROM layoffs_staging3
WHERE funds_raised_millions IS NOT NULL 
AND total_laid_off IS NOT NULL 
ORDER BY funds_raised_millions DESC;

WITH Funding_Brackets_CTE AS (
	SELECT *,
	CASE
		WHEN funds_raised_millions < 100 THEN 'Under $100M' 
		WHEN funds_raised_millions BETWEEN 100 AND 500 THEN '$100M - $500M'
		WHEN funds_raised_millions BETWEEN 500 AND 1000 THEN '$500M - $1B'
		WHEN funds_raised_millions > 1000 THEN 'Over $1B'
		ELSE 'NULL'
	END AS funding_brackets
	FROM layoffs_staging3
)
SELECT funding_brackets, COUNT(funding_brackets), ROUND(AVG(total_laid_off), 0) avg_laid_off, SUM(total_laid_off) sum_laid_off 
FROM Funding_Brackets_CTE
WHERE funds_raised_millions IS NOT NULL
GROUP BY funding_brackets;


-- Which companies laid off employees more than once?
SELECT company, industry, country, 
COUNT(company) layoff_rounds, SUM(total_laid_off) total_laid_off, 
MIN(`date`) start_date, MAX(`date`) end_date,
DATEDIFF(MAX(`date`), MIN(`date`)) days_between
FROM layoffs_staging3
WHERE total_laid_off IS NOT NULL
GROUP BY company, industry, country
HAVING COUNT(company) > 1
ORDER BY layoff_rounds DESC;


SELECT * 
FROM layoffs_staging3
WHERE company like 'Bolt%';

-- How did layoffs change year over year?
WITH Year_layoffs AS (
	SELECT YEAR(`date`) years, SUM(total_laid_off) total_layoffs, 
    LAG(SUM(total_laid_off), 1, 0) OVER(ORDER BY YEAR(`date`)) as previous_year_total
    FROM layoffs_staging3
    WHERE YEAR(`date`) IS NOT NULL
    GROUP BY years
)
SELECT *,
(total_layoffs - previous_year_total) year_over_year_diff, 
ROUND(((total_layoffs - previous_year_total)/previous_year_total) * 100, 1) percentage_diff 
FROM Year_layoffs;

SELECT * 
FROM layoffs_staging3;
-- Which funding stage had the most severe layoffs?"
SELECT stage, COUNT(stage) layoff_events, SUM(total_laid_off) total_laid_off,
AVG(total_laid_off) avg_laid_off, ROUND(AVG(percentage_laid_off), 2) avg_pct_laid_off
FROM layoffs_staging3
WHERE stage != 'Unknown' AND
stage IS NOT NULL
GROUP BY stage
ORDER BY avg_pct_laid_off DESC;


-- Which cities were hit hardest?
SELECT location, country, COUNT(location) layoff_events, SUM(total_laid_off) total_laid_off_per_city
FROM layoffs_staging3
WHERE total_laid_off IS NOT NULL
GROUP BY location, country
ORDER BY total_laid_off_per_city DESC
LIMIT 15;

SELECT industry, COUNT(industry) layoff_events, ROUND(AVG(percentage_laid_off), 2) avg_pct_laid_off,
SUM(total_laid_off) total_laid_off_per_industry
FROM layoffs_staging3
WHERE industry IS NOT NULL
AND percentage_laid_off
GROUP BY industry
ORDER BY avg_pct_laid_off DESC; 


-- Full profile of each company's layoff history
WITH Company_Profile AS (
	SELECT company, industry, country, COUNT(company) layoff_rounds,
	SUM(total_laid_off) sum_laid_off,  ROUND(AVG(percentage_laid_off), 2) avg_pct_laid_off,
	MIN(`date`) start_date, MAX(`date`) end_date, 
	DATEDIFF(MAX(`date`), MIN(`date`)) days_between,
	MAX(funds_raised_millions) funds_raised_millions
    FROM layoffs_staging3
    GROUP BY company, industry, country
)
SELECT *,
CASE
	WHEN layoff_rounds = 1 THEN 'Single Round'
    WHEN layoff_rounds BETWEEN 2 AND 3 THEN 'Multiple Rounds'
    ELSE 'Severe - Many Rounds'
END AS layoff_severity
FROM Company_Profile
ORDER BY sum_laid_off DESC;