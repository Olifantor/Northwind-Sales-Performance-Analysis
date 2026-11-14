# Northwind Sales Performance Analysis | PostgreSQL \& Power BI

## Project Overview

This end-to-end sales analytics project uses the Northwind dataset to explore revenue trends, product performance, customer contributions, discount patterns, and employee sales results. **PostgreSQL and SQL** are used for exploratory business analysis and validation; **Power BI** provides a four-page interactive dashboard with DAX-based measures.

## Business Objectives

* How has monthly revenue changed over time?
* What is the year-over-year revenue growth?
* Which products contribute the most to total revenue and units sold?
* How concentrated is revenue across products and customers?
* Where are customers located, and how does revenue vary geographically?
* What is the relationship between discount levels and purchase quantities?
* Which employees generate the highest revenue, order counts, and average order value?

## Project Workflow

**PostgreSQL Database → SQL Analysis \& Data Validation → Power BI Data Model → DAX Measures → Interactive Dashboard → Business Insights**

## Tools \& Technologies

* **PostgreSQL** — relational database management, querying, and sales data analysis.
* **DBeaver** — SQL development, database exploration, query execution, and data validation.
* **SQL** — JOINs, aggregations, Common Table Expressions (CTEs), window functions (`LAG()`, `RANK()`, `ROW\_NUMBER()`, `SUM() OVER`), and cumulative revenue calculations.
* **Microsoft Power BI Desktop** — importing PostgreSQL data, building relationships between tables, creating interactive reports, and designing a four-page sales performance dashboard.
* **DAX (Data Analysis Expressions)** — reusable measures for revenue, distinct order counts, average order value, quantities sold, and cumulative revenue analysis.
* **Business Intelligence \& Data Visualization** — KPI reporting, time-series trends, product and customer rankings, geographic analysis, Pareto analysis, and employee performance reporting.

## Dataset \& Methodology

The Northwind dataset includes transactional data from five principal tables: `orders`, `order\_details`, `products`, `customers`, and `employees`. The analyzed period runs from **July 2013 to May 6, 2015**.

Revenue is calculated consistently in SQL and Power BI as:

**Revenue = Unit Price × Quantity × (1 − Discount)**

The Power BI model relates customers and employees to orders, and orders and products to order details. Monetary figures are presented as **USD (assumed)**; the source dataset does not explicitly establish a currency.

## SQL Analysis

1. **Monthly Revenue Analysis:** Total monthly revenue and sales trends.
2. **Month-over-Month Growth:** Revenue changes calculated with `LAG()`.
3. **Year-over-Year Growth:** January–April 2014 versus January–April 2015.
4. **Product Performance \& Pareto Analysis:** Product revenue, quantity, ranking, and cumulative revenue contribution using `RANK()`, `ROW\_NUMBER()`, and windowed `SUM()`.
5. **Customer Analysis:** Revenue, order frequency, average order value, ranking, and revenue share.
6. **Discount Analysis:** Revenue and average quantity per order line across discount levels.
7. **Employee Sales Performance:** Revenue, distinct order counts, average order value, and employee ranking.

SQL scripts: [`sql/northwind\_sales\_analysis.sql`](sql/northwind_sales_analysis.sql)

## Power BI Dashboard

The report contains four pages:

### 1\. Sales Overview

* KPI cards for **Total Revenue**, **Total Orders**, and **Average Order Value**.
* **Monthly Revenue Trend** line chart to examine sales over time.
* A note identifying **May 2015 as a partial month**.

!\[Sales Overview](images/01\_sales\_overview.png)

### 2\. Product Performance

* **Top 10 Products by Revenue** and **Top 10 Products by Quantity Sold**.
* **Cumulative Revenue %** chart for product-level revenue concentration.
* Pareto summary: **36 of 77 products** account for approximately **80.2%** of revenue.

!\[Product Performance](images/02\_product\_performance.png)

### 3\. Customer \& Geographic Analysis

* **Top 10 Customers by Revenue**.
* Geographic map of customer revenue by location.
* **Customer Revenue Concentration** comparison: top three customers versus all other customers.

!\[Customer \& Geographic Analysis](images/03\_customer\_geographic\_analysis.png)

### 4\. Employee Analysis

* **Revenue by Employee**.
* **Orders by Employee**.
* **Average Order Value by Employee**.

!\[Employee Analysis](images/04\_employee\_analysis.png)

### Power BI Modeling \& Reporting

The Power BI report uses a relational model connecting orders and order details with customer, employee, and product dimensions. Reusable DAX measures support consistent KPI calculations across visuals. The report combines KPI cards, line and bar charts, a geographic map, and revenue concentration visuals. The cumulative revenue chart uses tooltips rather than crowded data labels.

### Selected DAX Measures

The report uses measures including:

```dax
Total Revenue =
SUMX(
    'public order\_details',
    'public order\_details'\[unitPrice] \*
    'public order\_details'\[quantity] \*
    (1 - 'public order\_details'\[discount])
)

Total Orders =
DISTINCTCOUNT('public orders'\[orderID])

Average Order Value =
DIVIDE(\[Total Revenue], \[Total Orders], 0)
```

Additional measures support product ranking, cumulative revenue percentage, and top-three customer revenue share. The displayed **36 / 77** Pareto summary is based on the full-dataset analysis and is **not a dynamic KPI** when filters change.

Power BI file: [`powerbi/Northwind\_Sales\_Analysis.pbix`](powerbi/Northwind_Sales_Analysis.pbix)

## Key Business Insights

* **Revenue Growth:** Revenue increased by **120.72%** from January–April 2014 to January–April 2015.
* **Product Performance:** Côte de Blaye generated the highest product revenue, accounting for approximately **11.17%** of total sales revenue. Camembert Pierrot had the highest quantity sold; Raclette Courdavault appeared in the most order lines.
* **Revenue Concentration:** The top **36 of 77 products (46.75%)** generated approximately **80.2%** of revenue. This is not a classic 80/20 Pareto distribution.
* **Customer Performance:** The three highest-revenue customers contributed approximately **25.24%** of total revenue.
* **Discount Analysis:** Order lines with a **25% discount** contained approximately **30% more units on average** than non-discounted lines. This is an association, not proof of causation.
* **Employee Performance:** Margaret Peacock generated approximately **232,890.85** in revenue across **156 orders**.

## Data Quality \& Limitations

* The dataset ends on **May 6, 2015**, so May 2015 is incomplete. Its apparent month-over-month revenue decline should not be interpreted as full-month deterioration.
* Year-over-year analysis compares equivalent January–April periods.
* Discount comparisons are descriptive and do not establish causation.
* Some product and customer names required correction of corrupted special characters in the source data.
* Currency is labeled **USD as an assumption**, rather than a verified source attribute.
* The static Pareto summary describes the unfiltered dataset; filter-dependent interpretation should use the interactive chart.

## Project Structure

```text
Northwind-Sales-Performance-Analysis/
├── README.md
├── sql/
│   └── northwind\_sales\_analysis.sql
├── powerbi/
│   └── Northwind\_Sales\_Analysis.pbix
└── images/
    ├── 01\_sales\_overview.png
    ├── 02\_product\_performance.png
    ├── 03\_customer\_geographic\_analysis.png
    └── 04\_employee\_analysis.png
```

## How to Explore the Project

1. Review the **Key Business Insights** and dashboard screenshots above.
2. Open the SQL file to inspect the underlying calculations and analysis.
3. Download the `.pbix` file and open it in **Power BI Desktop** to explore the report interactively. A local PostgreSQL connection may be needed to refresh the data; the published screenshots do not require Power BI.

## Skills Demonstrated

SQL querying, relational joins, CTEs, window functions, revenue analysis, business KPI design, relational data modeling, DAX measures, Power BI dashboard development, data quality checks, and business insight communication.

