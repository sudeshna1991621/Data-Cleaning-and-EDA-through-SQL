-- EDA: Use the layoff database
USE layoff_db;

-- Display all records from layoff_staging2
SELECT * FROM layoff_staging2;

-- Find the maximum values from total_laid_off and percentage_laid_off
SELECT 
    MAX(total_laid_off) AS max_total_laid_off,
    MAX(percentage_laid_off) AS max_percentage_laid_off
FROM layoff_staging2;

-- Subquery to get details where percentage_laid_off is maximum
SELECT * 
FROM layoff_staging2 
WHERE percentage_laid_off = (
    SELECT MAX(percentage_laid_off) 
    FROM layoff_staging2
);

-- Get layoff details where percentage_laid_off is 100%, ordered by funds raised
SELECT * 
FROM layoff_staging2 
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Display all records again
SELECT * FROM layoff_staging2;

-- Find the date range of the records
SELECT 
    MIN(`date`) AS start_date,
    MAX(`date`) AS end_date
FROM layoff_staging2;

-- Company-wise total layoffs, ordered by total layoffs
SELECT 
    company,
    SUM(total_laid_off) AS total_laid_off
FROM layoff_staging2
GROUP BY company
ORDER BY total_laid_off DESC;

-- Industry-wise total layoffs, ordered by total layoffs
SELECT 
    industry,
    SUM(total_laid_off) AS total_laid_off
FROM layoff_staging2
GROUP BY industry
ORDER BY total_laid_off DESC;

-- Country-wise total layoffs, ordered by total layoffs
SELECT 
    country,
    SUM(total_laid_off) AS total_laid_off
FROM layoff_staging2
GROUP BY country
ORDER BY total_laid_off DESC;

-- Year-wise total layoffs, ordered by total layoffs
SELECT 
    YEAR(`date`) AS year,
    SUM(total_laid_off) AS total_laid_off
FROM layoff_staging2
GROUP BY year
ORDER BY total_laid_off DESC;

-- Stage-wise total layoffs, ordered by total layoffs
SELECT 
    stage,
    SUM(total_laid_off) AS total_laid_off
FROM layoff_staging2
GROUP BY stage
ORDER BY total_laid_off DESC;

-- Company-wise average percentage layoffs, ordered by average percentage
SELECT 
    company,
    AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM layoff_staging2
GROUP BY company
ORDER BY avg_percentage_laid_off DESC;

-- Stored procedure to get rolling sum of total_laid_off by date for a specific company
DELIMITER $$

CREATE PROCEDURE company_layoff(IN com TEXT)
BEGIN
    WITH cte_rolling AS (
        SELECT 
            company,
            `date`,
            total_laid_off,
            SUM(total_laid_off) OVER (PARTITION BY company ORDER BY `date`) AS rolling_sum
        FROM layoff_staging2
    )
    SELECT 
        company,
        `date`,
        total_laid_off,
        rolling_sum 
    FROM cte_rolling 
    WHERE company = com;
END $$

DELIMITER ;

-- Call the stored procedure for Amazon
CALL company_layoff('Amazon');

-- CTE to find month-wise rolling sum of total_laid_off
WITH cte_rolling_sum AS (
    SELECT 
        SUBSTRING(`date`, 1, 7) AS `Month`, 
        SUM(total_laid_off) AS total_laidoff
    FROM layoff_staging2 
    WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
    GROUP BY `Month`
    ORDER BY `Month`
)
SELECT 
    `Month`, 
    total_laidoff,
    SUM(total_laidoff) OVER (ORDER BY `Month`) AS roll_sum 
FROM cte_rolling_sum;
