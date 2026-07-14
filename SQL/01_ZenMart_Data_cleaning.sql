-- ============================================================
-- ZenMart Nigeria — SQL Data Analysis Project
-- File: 01_ZenMart_Data_cleaning.sql
-- Author: Rasheed A. Tijani
-- Description: All data quality fixes after CSV import
-- ============================================================

USE zenmart;


-- ------------------------------------------------------------
-- BEFORE CLEANING: Preview the raw data
-- ------------------------------------------------------------

SELECT * FROM orders LIMIT 5;

-- Check total number of records imported
SELECT COUNT(*) AS Total_Records FROM orders;

-- Expected: 50 records


-- ------------------------------------------------------------
-- FIX 1: Remove Commas From Unit_Price
-- ------------------------------------------------------------

-- Problem: CSV export added commas to numbers
-- e.g. 185,000 instead of 185000
-- SQL reads them as text, making revenue calculations wrong

-- Step 1: Check the problem first
SELECT Order_ID, Unit_Price FROM orders LIMIT 5;

-- Step 2: Remove the commas
UPDATE orders
SET Unit_Price = REPLACE(Unit_Price, ',', '');

-- Step 3: Verify the fix
SELECT Order_ID, Unit_Price FROM orders LIMIT 5;

-- Expected: 185000 (no comma)

-- Step 4: Convert to proper number type
ALTER TABLE orders MODIFY COLUMN Unit_Price DECIMAL(10,2);


-- ------------------------------------------------------------
-- FIX 2: Remove Commas From Shipping_Cost
-- ------------------------------------------------------------

-- Same problem as Unit_Price

-- Step 1: Remove the commas
UPDATE orders
SET Shipping_Cost = REPLACE(Shipping_Cost, ',', '');

-- Step 2: Verify the fix
SELECT Order_ID, Shipping_Cost FROM orders LIMIT 5;

-- Step 3: Convert to proper number type
ALTER TABLE orders MODIFY COLUMN Shipping_Cost DECIMAL(10,2);


-- ------------------------------------------------------------
-- FIX 3: Fix Order_Date Format
-- ------------------------------------------------------------

-- Problem: Dates imported as text in DD/MM/YYYY format
-- SQL date functions like MONTH() return NULL on text dates

-- Step 1: Check the problem
SELECT Order_ID, Order_Date FROM orders LIMIT 5;
-- Shows: 03/01/2024 (text format — not a proper DATE)

-- Step 2: Add a new clean date column
ALTER TABLE orders ADD COLUMN Order_Date_Clean DATE;

-- Step 3: Convert text dates to proper DATE format
UPDATE orders
SET Order_Date_Clean = STR_TO_DATE(Order_Date, '%d/%m/%Y');

-- Step 4: Verify the fix
SELECT Order_ID, Order_Date, Order_Date_Clean FROM orders LIMIT 5;

-- Expected:
-- Order_Date: 03/01/2024  →  Order_Date_Clean: 2024-01-03
	

-- ------------------------------------------------------------
-- FIX 4: Fix Ship_Date Format (same as Order_Date)
-- ------------------------------------------------------------

ALTER TABLE orders ADD COLUMN Ship_Date_Clean DATE;

UPDATE orders
SET Ship_Date_Clean = STR_TO_DATE(Ship_Date, '%d/%m/%Y');

-- Verify
SELECT Order_ID, Ship_Date, Ship_Date_Clean FROM orders LIMIT 5;


-- ------------------------------------------------------------
-- VERIFICATION: Final data quality check
-- ------------------------------------------------------------

-- Check for NULL dates (Pending/Cancelled orders)
SELECT 
    Order_ID,
    Order_Status,
    Order_Date_Clean,
    Ship_Date_Clean
FROM orders
WHERE Ship_Date_Clean IS NULL;


-- Check order status distribution
SELECT 
    Order_Status,
    COUNT(*) AS Total
FROM orders
GROUP BY Order_Status;

-- Expected:
-- Delivered: 46
-- Pending:    3
-- Cancelled:  1

-- Final preview of clean data
SELECT 
    Order_ID,
    Customer_ID,
    Order_Date_Clean,
    Region,
    Category,
    Product_Name,
    Quantity,
    Unit_Price,
    Discount,
    Shipping_Cost,
    Order_Status
FROM orders
LIMIT 10;
