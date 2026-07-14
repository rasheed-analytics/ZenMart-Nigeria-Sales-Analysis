# ZenMart-Nigeria-Sales-Analysis

Project Overview

An end-to-end data analytics project analysing 50 orders across 4 Nigerian regions. Covers revenue performance, customer behaviour, product analysis, delivery operations, and loyalty tier insights.

Built by: Rasheed A. Tijani — Data Analyst

Tools: Microsoft Excel | MySQL | Power BI 

Scope: 50 orders, 44 customers, 27 products, 6 months (Jan–Jun 2024)

📊 Tools & Skills Used
Excel
Data cleaning, SUMIFS, VLOOKUP, Pivot Tables, IFS()

MySQL
Database design, JOINs, window functions, DATEDIFF

Power BI
KPI cards, DAX measures, slicers, interactive dashboard

📁 Repository Structure
zenmart-sql-analysis/
├── data/
│   ├── zenmart_orders.csv
│   └── zenmart_customers.csv
├── sql/
│   ├── 01_data_cleaning.sql
│   ├── 02_analysis_queries.sql
│   └── 03_window_functions.sql
├── dashboard/
│   └── ZenMart_Dashboard.png
└── README.md

💡 Key Business Insights
Total delivered revenue across all regions: ₦7,556,475 (H1 2024)
East region leads all regions in revenue at ₦2,336,950 (31%)
Electronics drives 67% of total revenue — iPhone 14 is top product at ₦1.7M
Only 4 of 44 customers are repeat buyers — loyalty program urgently needed
All regions deliver consistently within 4.9–5.0 days
January and May are peak revenue months
Platinum and Gold customers together drive 60% of total revenue
Average order value: ₦164,271 per delivered order

🧹 Data Cleaning (Excel)
Fix product name casing
=PROPER(G2)
Standardize text case
Flag missing Ship_Date
=IF(D2="","Not Yet Shipped","Shipped")
Identify pending orders
Calculate Delivery Days
=IF(D2="","N/A",D2-C2)
Measure delivery speed
Flag Discount Tier
=IFS(J2=0,"None",J2<=5,"Low",J2<=10,"Medium",J2>10,"High")
Group discounts
Total Sales
=H2*I2*(1-(J2/100))
Revenue after discount

🗄️ SQL Analysis
Data Fixes:
-- Fix commas in Unit_Price
UPDATE orders SET Unit_Price = REPLACE(Unit_Price, ',', '');

-- Fix date format
ALTER TABLE orders ADD COLUMN Order_Date_Clean DATE;
UPDATE orders SET Order_Date_Clean = STR_TO_DATE(Order_Date, '%d/%m/%Y');
Key Queries:
-- Total Revenue Per Region
SELECT Region,
    SUM(Quantity * Unit_Price * (1 - Discount/100.0)) AS Total_Revenue
FROM orders
WHERE Order_Status = 'Delivered'
GROUP BY Region
ORDER BY Total_Revenue DESC;

-- Top 5 Customers by Spend (JOIN)
SELECT o.Customer_ID, c.Full_Name, c.Loyalty_Tier,
    SUM(o.Quantity * o.Unit_Price * (1 - o.Discount/100.0)) AS Total_Spent
FROM orders o
JOIN customers c ON o.Customer_ID = c.Customer_ID
WHERE o.Order_Status = 'Delivered'
GROUP BY o.Customer_ID, c.Full_Name, c.Loyalty_Tier
ORDER BY Total_Spent DESC LIMIT 5;

-- Repeat Customers (HAVING)
SELECT o.Customer_ID, c.Full_Name, COUNT(o.Order_ID) AS Total_Orders
FROM orders o
JOIN customers c ON o.Customer_ID = c.Customer_ID
WHERE o.Order_Status = 'Delivered'
GROUP BY o.Customer_ID, c.Full_Name
HAVING COUNT(o.Order_ID) > 1
ORDER BY Total_Orders DESC;

-- Running Total (Window Function)
SELECT Order_ID, Order_Date_Clean,
    ROUND(Quantity * Unit_Price * (1 - Discount/100.0), 0) AS Order_Revenue,
    ROUND(SUM(Quantity * Unit_Price * (1 - Discount/100.0))
        OVER (ORDER BY Order_Date_Clean), 0) AS Running_Total
FROM orders WHERE Order_Status = 'Delivered'
ORDER BY Order_Date_Clean;

-- Rank Products by Revenue Per Category (Window Function)
SELECT Product_Name, Category,
    ROUND(SUM(Quantity * Unit_Price * (1 - Discount/100.0)), 0) AS Total_Revenue,
