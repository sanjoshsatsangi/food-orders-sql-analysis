# 🍽️ Food Orders SQL Analysis

**Tech Stack:** SQL Server · Star Schema Design · Data Cleaning · Business Analytics

---

## Overview

An end-to-end SQL data pipeline built on Indian food delivery data. The project covers data validation and cleaning, dimensional modelling (star schema), and deep-dive business analysis — all in SQL Server.

---

## Project Structure

```
food-orders-sql-analysis/
│
├── food_analysis.sql     ← Full query file (cleaning + schema + analysis)
├── food_data.csv         ← Raw dataset
└── README.md
```
## Schema
<img width="182" height="150" alt="svgviewer-output" src="https://github.com/user-attachments/assets/5ace4092-34ff-4437-b724-a6e60c4613d3" />



---

## What This Project Does

### 1. Data Validation & Cleaning
- Null checks across all 10 columns using conditional aggregation
- Blank/empty string detection
- Duplicate detection and removal using CTEs with `ROW_NUMBER()`

### 2. Star Schema Design

A proper dimensional model was built from the raw flat CSV:

**Fact Table**
- `fact_food_orders` — order_id, date_id, location_id, restaurant_id, category_id, dish_id, price_INR, rating, rating_count

**Dimension Tables**
- `dim_date` — Full date, year, month, quarter, day, week
- `dim_location` — State, city, location
- `dim_restaurant` — Restaurant name
- `dim_category` — Food category
- `dim_dish` — Dish name

> Schema diagram: see `schema.png` (or dbdiagram.io link below)

### 3. Business KPIs
- Total orders
- Total revenue (INR Million)
- Average dish price
- Average rating

### 4. Deep-Dive Analysis
- Monthly, quarterly, and yearly order trends
- Day-of-week order patterns
- Top 10 cities by order volume
- Revenue contribution by state
- Top 10 restaurants by revenue
- Top categories by order volume + avg rating
- Price range segmentation (5 buckets)
- Rating distribution

---

## Key Business Insights

| # | Insight | Finding |
|---|---------|---------|
| 1 | **Pricing** | The ₹100–299 price band drives the majority of orders. Premium items (₹500+) have low order frequency. |
| 2 | **Geography** | Top 10 cities dominate order volume. 2–3 states contribute the bulk of total revenue. |
| 3 | **Time trends** | Orders peak on weekends (Fri–Sun). Q3/Q4 shows a festive season demand spike. |
| 4 | **Quality gap** | High-order cuisines don't always have the best ratings — revealing improvement opportunity where demand already exists. |

---

## How to Run

1. Import `food_data.csv` into SQL Server as a table named `food_data`
2. Run `food_analysis.sql` top to bottom — sections are clearly labelled
3. Sections: Data Cleaning → Schema Creation → Data Insert → KPIs → Analysis

---

## Connecting to Power BI / Tableau

**Power BI:**
1. Home → Get Data → SQL Server → import all 6 tables
2. Verify 5 relationships in Model view (Many-to-One, Single cross-filter)
3. Build visuals: monthly trend (line), top cities (bar), category split (pie), KPI cards

**Tableau:**
1. Connect → Microsoft SQL Server → drag `fact_food_orders` to canvas
2. Drag each dimension table → use Relationships (not Joins) on FK fields
3. Build the same 4 chart types

---

## Skills Demonstrated

- Data cleaning and deduplication with CTEs
- Dimensional modelling (star schema)
- Aggregations, GROUP BY, HAVING, window functions
- Date functions: YEAR, MONTH, DATEPART, DATENAME
- Multi-table JOINs across a star schema
- Business KPI calculation and trend analysis
- Price segmentation with CASE statements

---

*Dataset: Indian food delivery orders | Tool: SQL Server Management Studio*
