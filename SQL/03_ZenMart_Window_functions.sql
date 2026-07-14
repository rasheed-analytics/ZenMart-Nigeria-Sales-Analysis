-- ============================================================
-- ZenMart Nigeria — SQL Data Analysis Project
-- File: 03_ZenMart_Window_functions.sql
-- Author: Rasheed A. Tijani
-- Description: Advanced window function queries
-- ============================================================

USE zenmart;

-- ============================================================
-- 1. ROW_NUMBER() Unique row numbers
-- ============================================================

-- Assign a unique row number to each order per region
SELECT 
    Order_ID,
    Region,
    Order_Date_Clean,
    ROUND(Quantity * Unit_Price * (1 - Discount/100.0), 0) AS Order_Revenue,
    ROW_NUMBER() OVER (
        PARTITION BY Region 
        ORDER BY Order_Date_Clean
    ) AS Row_Num
FROM orders
WHERE Order_Status = 'Delivered'
ORDER BY Region, Row_Num;



-- ============================================================
-- 2. RANK() Rank with gaps for ties
-- ============================================================

-- Rank customers by total spend
SELECT 
    o.Customer_ID,
    c.Full_Name,
    SUM(o.Quantity * o.Unit_Price * (1 - o.Discount/100.0)) AS Total_Spent,
    RANK() OVER (
        ORDER BY SUM(o.Quantity * o.Unit_Price * (1 - o.Discount/100.0)) DESC
    ) AS Spend_Rank
FROM orders o
JOIN customers c ON o.Customer_ID = c.Customer_ID
WHERE o.Order_Status = 'Delivered'
GROUP BY o.Customer_ID, c.Full_Name
ORDER BY Spend_Rank;


-- ============================================================
-- 3. DENSE_RANK() Rank without gaps
-- ============================================================

-- Rank products by revenue within each category (no gaps)
SELECT 
    Product_Name,
    Category,
    ROUND(SUM(Quantity * Unit_Price * (1 - Discount/100.0)), 0) AS Total_Revenue,
    DENSE_RANK() OVER (
        PARTITION BY Category
        ORDER BY SUM(Quantity * Unit_Price * (1 - Discount/100.0)) DESC
    ) AS `Dense_Rank`
FROM orders
WHERE Order_Status = 'Delivered'
GROUP BY Product_Name, Category
ORDER BY Category, `Dense_Rank`;


-- ============================================================
-- 4. SUM() OVER Running Total
-- ============================================================

-- Cumulative revenue over time
SELECT 
    Order_ID,
    Order_Date_Clean,
    ROUND(Quantity * Unit_Price * (1 - Discount/100.0), 0) AS Order_Revenue,
    ROUND(SUM(Quantity * Unit_Price * (1 - Discount/100.0))
        OVER (ORDER BY Order_Date_Clean), 0) AS Running_Total
FROM orders
WHERE Order_Status = 'Delivered'
ORDER BY Order_Date_Clean;


-- ============================================================
-- 5. SUM() OVER PARTITION BY Running Total Per Group
-- ============================================================

-- Separate running total for each region
SELECT 
    Order_ID,
    Order_Date_Clean,
    Region,
    ROUND(Quantity * Unit_Price * (1 - Discount/100.0), 0) AS Order_Revenue,
    ROUND(SUM(Quantity * Unit_Price * (1 - Discount/100.0))
        OVER (PARTITION BY Region ORDER BY Order_Date_Clean), 0) AS Running_Total_By_Region
FROM orders
WHERE Order_Status = 'Delivered'
ORDER BY Region, Order_Date_Clean;


-- ============================================================
-- 6. LAG() Previous Row Value
-- ============================================================

-- Compare each month's revenue with the previous month
SELECT 
    MONTHNAME(Order_Date_Clean) AS Month_Name,
    ROUND(SUM(Quantity * Unit_Price * (1 - Discount/100.0)), 0) AS Monthly_Revenue,
    LAG(ROUND(SUM(Quantity * Unit_Price * (1 - Discount/100.0)), 0))
        OVER (ORDER BY MONTH(Order_Date_Clean)) AS Previous_Month_Revenue
FROM orders
WHERE Order_Status = 'Delivered'
GROUP BY MONTH(Order_Date_Clean), MONTHNAME(Order_Date_Clean)
ORDER BY MONTH(Order_Date_Clean);


-- ============================================================
-- 7. LEAD() Next Row Value
-- ============================================================

-- Show each month's revenue alongside next month's revenue
SELECT 
    MONTHNAME(Order_Date_Clean) AS Month_Name,
    ROUND(SUM(Quantity * Unit_Price * (1 - Discount/100.0)), 0) AS Monthly_Revenue,
    LEAD(ROUND(SUM(Quantity * Unit_Price * (1 - Discount/100.0)), 0))
        OVER (ORDER BY MONTH(Order_Date_Clean)) AS Next_Month_Revenue
FROM orders
WHERE Order_Status = 'Delivered'
GROUP BY MONTH(Order_Date_Clean), MONTHNAME(Order_Date_Clean)
ORDER BY MONTH(Order_Date_Clean);


-- ============================================================
-- COMPARISON: GROUP BY vs WINDOW FUNCTIONS
-- ============================================================

-- GROUP BY collapses rows into groups
-- Shows only one row per region
SELECT 
    Region,
    SUM(Quantity * Unit_Price * (1 - Discount/100.0)) AS Total_Revenue
FROM orders
WHERE Order_Status = 'Delivered'
GROUP BY Region;

-- Window Function keeps all rows
-- Shows every order AND its region total alongside it
SELECT 
    Order_ID,
    Region,
    ROUND(Quantity * Unit_Price * (1 - Discount/100.0), 0) AS Order_Revenue,
    ROUND(SUM(Quantity * Unit_Price * (1 - Discount/100.0))
        OVER (PARTITION BY Region), 0)                     AS Region_Total
FROM orders
WHERE Order_Status = 'Delivered'
ORDER BY Region, Order_ID;


