-- ============================================================
-- Starbucks Analysis - SQL Script
-- Creates the database, tables, and runs the KPI queries
-- ============================================================


-- ------------------------------------------------------------
-- 1. SETUP: Create the database
-- ------------------------------------------------------------
CREATE DATABASE starbucks_analysis;
USE starbucks_analysis;


-- ------------------------------------------------------------
-- 2. CREATE THE NUTRITION TABLE
-- ------------------------------------------------------------
CREATE TABLE nutrition (
    id INT AUTO_INCREMENT PRIMARY KEY,
    beverage_category VARCHAR(50),
    beverage VARCHAR(100),
    beverage_prep VARCHAR(50),
    calories INT,
    total_fat_g DECIMAL(5,1),
    trans_fat_g DECIMAL(5,1),
    saturated_fat_g DECIMAL(5,1),
    sodium_mg INT,
    total_carbohydrates_g INT,
    cholesterol_mg INT,
    dietary_fibre_g INT,
    sugars_g INT,
    protein_g DECIMAL(5,1),
    vitamin_a_pct_dv INT,
    vitamin_c_pct_dv INT,
    calcium_pct_dv INT,
    iron_pct_dv DECIMAL(5,1),
    caffeine_mg DECIMAL(5,1)
);

-- Check the table was made correctly
DESCRIBE nutrition;


-- ------------------------------------------------------------
-- 3. CREATE THE STORES TABLE
-- ------------------------------------------------------------
DROP TABLE IF EXISTS stores;
CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(150),
    ownership_type VARCHAR(50),
    state_region VARCHAR(50),
    country_code VARCHAR(5),
    longitude DECIMAL(9,6),
    latitude DECIMAL(9,6)
);

-- Check the table was made correctly
DESCRIBE stores;


-- ------------------------------------------------------------
-- 4. CHECK THE DATA LOADED CORRECTLY
-- (Data is loaded using the Python notebook: 03_load_to_mysql)
-- ------------------------------------------------------------

-- Nutrition should have 242 rows
SELECT COUNT(*) FROM nutrition;

-- Should be 23 (the "Varies" caffeine values)
SELECT COUNT(*) FROM nutrition WHERE caffeine_mg IS NULL;

-- Look at the first few rows
SELECT * FROM nutrition LIMIT 5;

-- Stores should have 25,600 rows
SELECT COUNT(*) FROM stores;


-- ============================================================
-- KPI QUERIES (these feed the Tableau dashboard)
-- ============================================================


-- ------------------------------------------------------------
-- KPI CARDS: total drinks, average calories, sugar, caffeine
-- ------------------------------------------------------------
SELECT
    COUNT(*) AS total_beverages,
    ROUND(AVG(calories), 2) AS avg_calories,
    ROUND(AVG(sugars_g), 2) AS avg_sugar,
    ROUND(AVG(caffeine_mg), 2) AS avg_caffeine
FROM nutrition;


-- ------------------------------------------------------------
-- Average calories by category (highest first)
-- ------------------------------------------------------------
SELECT beverage_category, ROUND(AVG(calories), 2) AS avg_calories
FROM nutrition
GROUP BY beverage_category
ORDER BY avg_calories DESC;


-- ------------------------------------------------------------
-- Top 5 highest caffeine drinks
-- ------------------------------------------------------------
SELECT beverage, beverage_prep, caffeine_mg
FROM nutrition
ORDER BY caffeine_mg DESC
LIMIT 5;


-- ------------------------------------------------------------
-- How many drinks in each category (for the pie chart)
-- ------------------------------------------------------------
SELECT beverage_category, COUNT(*) AS beverage_count
FROM nutrition
GROUP BY beverage_category
ORDER BY beverage_count DESC;


-- ------------------------------------------------------------
-- Average caffeine by category (highest first)
-- ------------------------------------------------------------
SELECT beverage_category, ROUND(AVG(caffeine_mg), 2) AS avg_caffeine
FROM nutrition
GROUP BY beverage_category
ORDER BY avg_caffeine DESC;


-- ------------------------------------------------------------
-- Number of stores in each country (highest first)
-- ------------------------------------------------------------
SELECT country_code, COUNT(store_id) AS store_count
FROM stores
GROUP BY country_code
ORDER BY store_count DESC;


-- ------------------------------------------------------------
-- Total number of countries with a Starbucks
-- ------------------------------------------------------------
SELECT COUNT(DISTINCT country_code) AS total_countries FROM stores;


-- ------------------------------------------------------------
-- Total number of stores
-- ------------------------------------------------------------
SELECT COUNT(DISTINCT store_id) AS total_stores FROM stores;


-- ------------------------------------------------------------
-- Top 10 states/regions by number of stores
-- ------------------------------------------------------------
SELECT state_region, COUNT(store_id) AS store_count
FROM stores
GROUP BY state_region
ORDER BY store_count DESC
LIMIT 10;


-- ------------------------------------------------------------
-- How many stores can be shown on the map (have coordinates)
-- ------------------------------------------------------------
SELECT COUNT(store_id) AS stores_with_coordinates
FROM stores
WHERE latitude IS NOT NULL AND longitude IS NOT NULL;