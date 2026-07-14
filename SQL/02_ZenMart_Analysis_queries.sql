-- ============================================================
-- ZenMart Nigeria — SQL Data Analysis Project
-- File: 02_ZenMart_Analysis_queries.sql
-- Author: Rasheed A. Tijani
-- Description: All 9 business analysis queries
-- ============================================================

USE zenmart;

-- ============================================================
-- QUERY 1: Total Revenue Per Region
-- Which region is generating the most revenue?
-- ============================================================

SELECT 
    Region,
    SUM(Quantity * Unit_Price * (1 - Discount/100.0)) AS Total_Revenue
FROM orders
WHERE Order_Status = 'Delivered'
GROUP BY Region
ORDER BY Total_Revenue DESC;

-- Expected Results:
-- East:  2,336,950
-- South: 2,278,500
-- West:  1,683,950
-- North: 1,257,075



-- ============================================================
-- QUERY 2: Top 5 Customers by Spend
-- Who are our highest spending customers?
-- ============================================================

SELECT 
    Customer_ID,
    COUNT(Order_ID) AS Total_Orders,
    SUM(Quantity * Unit_Price * (1 - Discount/100.0)) AS Total_Spent
FROM orders
WHERE Order_Status = 'Delivered'
GROUP BY Customer_ID
ORDER BY Total_Spent DESC
LIMIT 5;

-- Expected Results:
-- Usman Kalu   	895600
-- Nuhu Garba   	850000
-- Emeka Nwosu	    608700
-- Tunde Ojo	    548400
-- Ibrahim Bello 	527250



-- ============================================================
-- QUERY 3: Top 5 Customers With Names (JOIN)
-- Who are our top customers with full details?
-- ============================================================

SELECT 
    o.Customer_ID,
    c.Full_Name,
    c.City,
    c.Loyalty_Tier,
    COUNT(o.Order_ID) AS Total_Orders,
    SUM(o.Quantity * o.Unit_Price * (1 - o.Discount/100.0)) AS Total_Spent
FROM orders o
JOIN customers c ON o.Customer_ID = c.Customer_ID
WHERE o.Order_Status = 'Delivered'
GROUP BY o.Customer_ID, c.Full_Name, c.City, c.Loyalty_Tier
ORDER BY Total_Spent DESC
LIMIT 5;

-- Expected Results:
-- Usman Kalu     | Port Harcourt | Platinum | 895,600
-- Nuhu Garba     | Abuja         | Bronze   | 850,000
-- Emeka Nwosu    | Ibadan        | Gold     | 608,700
-- Tunde Ojo      | Lagos         | Platinum | 548,400
-- Ibrahim Bello  | Abuja         | Silver   | 527,250



-- ============================================================
-- QUERY 4: Monthly Revenue Trend
-- This only works on Order_Date_Clean (proper DATE column)
-- How is revenue trending month by month?
-- ============================================================

SELECT 
    MONTH(Order_Date_Clean) AS Month_Number,
    MONTHNAME(Order_Date_Clean) AS Month_Name,
    COUNT(Order_ID) AS Total_Orders,
    SUM(Quantity * Unit_Price * (1 - Discount/100.0)) AS Total_Revenue
FROM orders
WHERE Order_Status = 'Delivered'
GROUP BY MONTH(Order_Date_Clean), MONTHNAME(Order_Date_Clean)
ORDER BY Month_Number;

-- Expected Results:
-- January:  10 orders | 2,249,450
-- February:  8 orders | 1,085,950
-- March:    8 orders | 1,032,450
-- April:    10 orders | 1,302,525
-- May:      9 orders | 1,838,100
-- June:      1 order  |    48,000



-- ============================================================
-- QUERY 5: Repeat Customers
-- Which customers placed more than one order?
-- ============================================================

SELECT 
    o.Customer_ID,
    c.Full_Name,
    c.Loyalty_Tier,
    COUNT(o.Order_ID) AS Total_Orders
FROM orders o
JOIN customers c ON o.Customer_ID = c.Customer_ID
WHERE o.Order_Status = 'Delivered'
GROUP BY o.Customer_ID, c.Full_Name, c.Loyalty_Tier
HAVING COUNT(o.Order_ID) > 1
ORDER BY Total_Orders DESC;

-- Expected Results:
-- Tunde Ojo    | Platinum | 3 orders
-- Amina Bello  | Gold     | 2 orders
-- Emeka Nwosu  | Gold     | 2 orders
-- Usman Kalu   | Platinum | 2 orders



-- ============================================================
-- QUERY 6: Average Delivery Time Per Region
-- How fast does ZenMart deliver in each region?
-- ============================================================

SELECT 
    Region,
    ROUND(AVG(DATEDIFF(STR_TO_DATE(Ship_Date, '%d/%m/%Y'),
        Order_Date_Clean)), 1) AS Avg_Delivery_Days
FROM orders
WHERE Order_Status = 'Delivered'
GROUP BY Region
ORDER BY Avg_Delivery_Days ASC;

-- Expected Results:
-- North: 4.9 days
-- South: 4.9 days
-- East:  5.0 days
-- West:  5.0 days



-- ============================================================
-- QUERY 7: Revenue by Loyalty Tier
-- Which customer loyalty tier generates the most revenue?
-- ============================================================

SELECT 
    c.Loyalty_Tier,
    COUNT(DISTINCT o.Customer_ID)  AS Total_Customers,
    COUNT(o.Order_ID) AS Total_Orders,
    SUM(o.Quantity * o.Unit_Price * (1 - o.Discount/100.0)) AS Total_Revenue
FROM orders o
JOIN customers c ON o.Customer_ID = c.Customer_ID
WHERE o.Order_Status = 'Delivered'
GROUP BY c.Loyalty_Tier
ORDER BY Total_Revenue DESC;

-- Expected Results:
-- Platinum: 2,304,750
-- Gold:     2,279,525
-- Silver:   1,501,100
-- Bronze:   1,471,100



-- ============================================================
-- QUERY 8: Running Total (Window Function)
-- How is revenue accumulating over time?
-- ============================================================

SELECT 
    Order_ID,
    Order_Date_Clean,
    Region,
    ROUND(Quantity * Unit_Price * (1 - Discount/100.0), 0) AS Order_Revenue,
    ROUND(SUM(Quantity * Unit_Price * (1 - Discount/100.0)) 
        OVER (ORDER BY Order_Date_Clean), 0) AS Running_Total
FROM orders
WHERE Order_Status = 'Delivered'
ORDER BY Order_Date_Clean;

-- Sample Results:
-- Order 1001 | 03/01/2024 | 351,500   | 351,500   (running total starts)
-- Order 1002 | 05/01/2024 | 121,500   | 473,000
-- Order 1003 | 08/01/2024 | 110,000   | 583,000
-- ...
-- Order 1050 | 06/06/2024 | 48,000    | 7,556,475 (final total)

-- ============================================================
-- BONUS: Running Total by Region (PARTITION BY)
-- ============================================================

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
-- QUERY 9: Rank Products by Revenue (Window Function)
-- What is the best selling product in each category?
-- ============================================================

SELECT 
    Product_Name,
    Category,
    ROUND(SUM(Quantity * Unit_Price * (1 - Discount/100.0)), 0) AS Total_Revenue,
    RANK() OVER (
        PARTITION BY Category 
        ORDER BY SUM(Quantity * Unit_Price * (1 - Discount/100.0)) DESC
    ) AS Rank_In_Category
FROM orders
WHERE Order_Status = 'Delivered'
GROUP BY Product_Name, Category
ORDER BY Category, Rank_In_Category;

-- Expected Top Ranked Products Per Category:
-- Electronics: iPhone 14           | 1,700,000
-- Clothing:    Premium Silk Abaya  |   324,000
-- Furniture:   Executive Office Chair | 255,000
-- Food:        Basmati Rice 50kg   |   154,000