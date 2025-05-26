
-- Data Cleaning

CREATE DATABASE layoff_db;
USE layoff_db;

-- 0. Load initial data
SELECT * FROM layoffs;

-- 1. Remove Duplicates
-- Create staging table
CREATE TABLE layoff_staging AS 
SELECT * FROM layoffs;

SELECT * FROM layoff_staging;

-- Identify duplicates using ROW_NUMBER
WITH cte_layoff AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
                              `date`, stage, country, funds_raised_millions) AS row_num 
    FROM layoff_staging
)
SELECT * FROM cte_layoff WHERE row_num > 1;

-- Delete duplicates
WITH cte_layoff AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
                              `date`, stage, country, funds_raised_millions) AS row_num 
    FROM layoff_staging
)
DELETE FROM cte_layoff WHERE row_num > 1;

-- Create layoff_staging2 table with row_num
CREATE TABLE layoff_staging2 (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT DEFAULT NULL,
    percentage_laid_off TEXT,
    `date` TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT DEFAULT NULL,
    row_num INT
);

-- Insert cleaned data into layoff_staging2
INSERT INTO layoff_staging2
SELECT *, ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
                             `date`, stage, country, funds_raised_millions) AS row_num 
FROM layoff_staging;

-- Disable safe updates
SET SQL_SAFE_UPDATES = 0;

-- Remove duplicates from layoff_staging2
DELETE FROM layoff_staging2 WHERE row_num > 1;

-- 2. Standardize Data
-- Trim company name whitespace
UPDATE layoff_staging2 SET company = TRIM(company);

-- Standardize 'Crypto' industry name
SELECT industry FROM layoff_staging2 WHERE industry LIKE 'Crypto%';
UPDATE layoff_staging2 SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';

-- Standardize country names by removing trailing '.'
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) FROM layoff_staging2 ORDER BY 1;
UPDATE layoff_staging2 SET country = TRIM(TRAILING '.' FROM country) WHERE country LIKE '%.';

-- Convert date from text to proper DATE format
SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y') FROM layoff_staging2;
UPDATE layoff_staging2 SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
ALTER TABLE layoff_staging2 MODIFY `date` DATE;

-- 3. Handle Null or Blank Values
-- Find rows with both total_laid_off and percentage_laid_off NULL
SELECT COUNT(*) FROM layoff_staging2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Find and replace blank industry with NULL
SELECT * FROM layoff_staging2 WHERE industry IS NULL OR industry = '';
UPDATE layoff_staging2 SET industry = NULL WHERE industry = '';

-- Use self join to impute missing industry
SELECT * FROM layoff_staging2 t1
JOIN layoff_staging2 t2 ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '') AND t2.industry IS NOT NULL;

UPDATE layoff_staging2 t1
JOIN layoff_staging2 t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '') AND t2.industry IS NOT NULL;

-- Delete fully NULL layoff rows
DELETE FROM layoff_staging2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- 4. Remove row_num column after cleaning
ALTER TABLE layoff_staging2 DROP COLUMN row_num;
