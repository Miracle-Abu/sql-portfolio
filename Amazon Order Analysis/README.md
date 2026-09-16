### 🛒 Amazon Order Analysis

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

