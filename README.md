# SQL Portfolio

A collection of real-world SQL projects demonstrating data cleaning, exploratory data analysis (EDA) and advanced querying using MySQL.

---

## 🛠️ Tools & Skills
- **Database:** MySQL
- **Skills:** Data Cleaning, Exploratory Data Analysis, Window Functions, CTEs, Subqueries, Stored Procedures, Triggers, Joins, Aggregations, Temp Tables

---

## 📁 Projects

---

### 1. 🏢 Company Layoffs Analysis (2020–2023)
**Folder:** `Company Layoff Analysis`

#### Overview
Analysis of global tech company layoffs from 2020 to 2023, covering data cleaning and in-depth exploratory data analysis to uncover trends and patterns.

#### Data Cleaning
- Removed duplicate records using `ROW_NUMBER()` and staging tables
- Standardized inconsistent industry names (e.g. Crypto, CryptoCurrency → Crypto)
- Handled NULL and blank values
- Converted date columns from TEXT to DATE format
- Removed redundant columns

#### Key Findings
- **2022** saw a **900%+ jump** in layoffs compared to 2021 — driven by rising interest rates and the collapse of the post-COVID tech boom
- **San Francisco Bay Area** was the hardest hit city with **430+ layoff events** and over **125,000 jobs lost**
- **Seed stage** companies had the highest average percentage of workforce laid off (~70%)
- Rolling monthly totals revealed the layoff crisis peaked in early 2023

#### SQL Concepts Demonstrated
- `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()` — Window Functions
- CTEs and Subqueries
- `GROUP BY`, `HAVING`, `ORDER BY`
- `STR_TO_DATE()`, `TRIM()`, `LIKE` — String Functions
- Self JOINs for data population
- Rolling totals with `SUM() OVER(ORDER BY)`

---

### 2. 🏠 Nashville Housing Data Cleaning (2013–2016)
**Folder:** `Nashville Housing Data`

#### Overview
Comprehensive data cleaning project on a Nashville, Tennessee real estate dataset with 56,000+ property sales records.

#### Data Cleaning Steps
- Imported 56,636 rows using `LOAD DATA INFILE`
- Removed 104 duplicate records using `ROW_NUMBER()` and staging tables
- Dropped redundant columns
- Trimmed whitespace and removed hidden carriage return characters (`\r`) using `HEX()` detection
- Standardized `land_use` categories
- Converted `sale_date` from TEXT to DATE format using `STR_TO_DATE()`
- Converted numeric columns from TEXT to proper INT/DECIMAL types using `NULLIF()` and `ALTER TABLE`
- Populated missing `property_address` and `property_city` using self JOINs on `parcel_id`

#### Key Findings
- **Vacant Commercial Land** had the highest average sale price
- **Single Family** homes had the most sales — the most common property type
- **3 bedroom** properties were the most common
- The top 10 most expensive sales were **7 condo units at the same address** sold in a bulk purchase — a real world data anomaly
- **72%** of properties had `total_value = land_value + building_value`

#### SQL Concepts Demonstrated
- `LOAD DATA INFILE` — Fast CSV importing
- `NULLIF()` — Converting empty strings to NULL
- `HEX()` — Detecting hidden characters
- `TRIM(TRAILING)` — Removing specific trailing characters
- `MODIFY COLUMN` — Changing column data types
- Self JOINs for NULL population
- `ALTER TABLE DROP COLUMN` — Removing redundant columns

---

### 3. 🌍 World Population Analysis
**Folder:** `World Population Analysis`

#### Overview
Exploratory data analysis of global population data across 234 countries spanning from 1970 to 2022.

#### Key Findings
- **China and India** are the only 'Major Power' nations — just **7 countries** account for **51% of the world's population**
- **UAE and Qatar** had the highest population growth since 1970 — driven by oil wealth
- **Macau** is the most densely populated territory; **Greenland** the least
- **142 countries** (61%) are in the 'Slowly Growing' band
- World population growth is **decelerating** over time

#### SQL Concepts Demonstrated
- `UNION ALL` — Unpivoting year columns into rows
- `LAG()` — Year over year growth calculations
- `DENSE_RANK()` — Top 3 countries per continent
- `SUM() OVER()` — Running totals of world population percentage
- `CROSS JOIN` — Generating all possible combinations
- CTEs and Window Functions
- `CASE` statements for population categorization

---

### 4. 😊 World Happiness Report Analysis (2015–2017)
**Folder:** `World Happiness Report Analysis`

#### Overview
Multi-year exploratory data analysis of the World Happiness Report comparing happiness scores, rankings and contributing factors (Economy, Family, Health, Freedom, Trust, Generosity) across 150+ countries between 2015, 2016 and 2017.

#### Key Findings
- **Economy (GDP per Capita)** and **Family** are the largest contributors to happiness scores globally
- **Western Europe** dominates global happiness rankings — 7 of the 10 countries consistently in the top 10 across all 3 years are Western European
- **Norway** topped the 2017 rankings, overtaking Denmark and Switzerland
- Built reusable **stored procedures** for regional happiness/sadness analysis per year
- Identified each country's **dominant happiness factor** using `GREATEST()` combined with `CASE`
- Tracked **year-over-year trends** across 3 years labeling countries as Improving, Declining or Stable

#### SQL Concepts Demonstrated
- `GREATEST()` — Finding the maximum value across multiple columns
- CTEs combined with `RANK()` — Regional and category-based rankings
- Stored Procedures with `IN` parameters — Reusable country profile lookups
- 3-table `JOIN` across yearly datasets — Multi-year comparison
- `LEFT JOIN` / `RIGHT JOIN` — Identifying countries present in one year but not another
- Temporary Tables — Consolidated multi-metric analysis table
- `CASE` statements — Trend categorization (Improving/Declining/Stable)
- `ALTER TABLE RENAME COLUMN` — Standardizing column names across datasets

---

### 5. 🛒 Amazon Order Analysis
**Folder:** `Amazon Order Analysis`

#### Overview
Data cleaning and exploratory data analysis on an Amazon sales dataset with 10,000 orders covering products, customers, revenue and shipping across multiple categories.

#### Data Cleaning
- Converted date columns to proper DATE format using `STR_TO_DATE()`
- Rounded `total_sales` to 2 decimal places
- Fixed logically impossible delivery dates (delivery before shipping) — set to NULL
- Corrected country data inconsistency (US states labeled as India)
- Verified zero duplicates and zero NULLs across all 21 columns

#### Key Findings
- Identified **4,882 orders (49%)** with impossible delivery dates — confirming synthetic data generation
- **Electronics** generated the highest total revenue
- **Card payments** were the most popular payment method
- Higher discount brackets did not always correlate with higher revenue
- Shipping cost as a percentage of order value varied significantly across categories

#### SQL Concepts Demonstrated
- `DATEDIFF()` — Detecting impossible date ranges
- `UPDATE` with conditional `WHERE` — Fixing data anomalies
- CTEs with subqueries — Percentage calculations
- `MONTHNAME()` and `MONTH()` — Time-based trend analysis
- `CASE` statements — Discount bracket categorization
- Window Functions — Ranking and aggregation
- Multi-column `GROUP BY` — Category and sub-category analysis

---
