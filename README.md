# 🧹 Layoff Data Cleaning & Analysis with SQL

## 📘 Project Overview

This project involves cleaning, transforming, and analyzing a layoff dataset using MySQL. The dataset initially contains duplicates, inconsistent formatting, null values, and non-standard entries. The goal is to clean the data and perform exploratory data analysis (EDA) to extract key insights, trends, and patterns related to layoffs across companies, industries, and countries.

---

## 📂 Database & Table Structure

- **Database:** `layoff_db`
- **Staging Table:** `layoff_staging`
- **Cleaned Table:** `layoff_staging2`

---

## ⚙️ Steps Performed

### 1. ✅ Data Loading & Initial Exploration
- Created and used the `layoff_db` database.
- Loaded initial data into `layoff_staging`.

### 2. 🔁 Removing Duplicates
- Used `ROW_NUMBER()` with a CTE to identify duplicates.
- Deleted rows with `row_num > 1`.
- Verified duplicate removal in `layoff_staging2`.

### 3. 🧽 Standardizing Data
- Trimmed white spaces in `company` names.
- Standardized `industry` values (e.g., all variations of "Crypto").
- Cleaned `country` values by removing trailing dots.
- Converted `date` column from `TEXT` to `DATE` format using `STR_TO_DATE`.

### 4. 🚫 Handling Null/Blank Values
- Removed rows where both `total_laid_off` and `percentage_laid_off` were `NULL`.
- Replaced blank `industry` fields with `NULL`.
- Used a self-join to impute missing industry values using other entries of the same company.

### 5. 🧼 Finalizing the Clean Table
- Dropped `row_num` column after cleaning.
- The cleaned table is `layoff_staging2`.

---

## 📊 Exploratory Data Analysis (EDA)

- **General Overview**
  - Displayed all cleaned records.
  - Examined date range of data using `MIN(date)` and `MAX(date)`.

- **Summary Metrics**
  - Maximum values for `total_laid_off` and `percentage_laid_off`.
  - Companies with 100% layoffs, sorted by `funds_raised_millions`.

- **Aggregations**
  - Total layoffs by:
    - Company
    - Industry
    - Country
    - Year
    - Stage of company

- **Advanced Metrics**
  - Average `percentage_laid_off` per company.
  - Rolling sum of layoffs per company over time (via stored procedure).
  - Month-wise rolling sum of layoffs using a CTE.

---

## 🔄 Stored Procedure

A stored procedure named `company_layoff` was created to generate a rolling sum of `total_laid_off` for a specified company.

## 🧠 Learnings
- Practical use of CTEs, `ROW_NUMBER()`, `JOIN`s, and Stored Procedures
- Data cleaning strategies in SQL
- Deriving insights through SQL-based EDA
- Real-world handling of missing and inconsistent data
