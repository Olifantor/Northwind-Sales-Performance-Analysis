
-- PROJECT: ANALYSIS OF NORTHWIND SALES


-- TASK 1 -- MONTHLY REVENUE OF SALES
-- Calculates total monthly revenue after discounts

select 
extract ( year from o."orderDate" ::date) as year,
extract ( month from o."orderDate" ::date) as month,
round(sum( od."unitPrice" * od."quantity" * (1-od."discount"))::numeric,2) as revenue
from orders o
join order_details od
on od."orderID" = o."orderID"
group by year, month
order by year, month;



-- TASK 2 -- MONTH-OVER-MONTH REVENUE GROWTH

-- Formula : (( Current revenue - Previous revenue )
--              / Previous revenue) * 100
-- Measures monthly revenue growth or decline 

with revenue_by_year_month as (
select 
extract ( year from o."orderDate" ::date) as year,
extract ( month from o."orderDate" ::date) as month,
round(sum( od."unitPrice" * od."quantity" * (1-od."discount"))::numeric,2) as revenue
from orders o
join order_details od
on od."orderID" = o."orderID"
group by year, month
order by year, month)
select 
year,
month,
revenue,
round(LAG(revenue) over( order by year, month),2) as previous_revenue,
round(((revenue - LAG(revenue) over( order by year, month)) / LAG(revenue) over( order by year, month) * 100),2) as MoM_growth_percent
from revenue_by_year_month 
group by year,month,revenue 
order by year, month,revenue;

-- BUSINESS INSIGHT:
-- Monthly revenue fluctuated throughout the analyzed period.
-- Revenue declined by 8.53% in August 2013 compared to July,
-- followed by a 3.52% increase in September.
-- December 2014 recorded approximately 64% MoM revenue growth.
-- May 2015 showed an 85.19% revenue decline compared to April 2015.
-- However, May 2015 contains incomplete monthly data,
-- so this decline should not be interpreted as a full-month
-- deterioration in sales performance.


-- TASK 3A  YEAR-OVER-YEAR REVENUE GROWTH 

-- Formula : (( Current Period Revenue - Previous Year Revenue)
--            / Previous Year Revenue ) * 100
-- January-April 2014 and 2015 are compared 
-- to ensure equivalent reporting periods


with revenue_by_year_month as (
select 
extract ( year from o."orderDate" ::date) as year,
extract ( month from o."orderDate" ::date) as month,
round(sum( od."unitPrice" * od."quantity" * (1-od."discount"))::numeric,2) as revenue
from orders o
join order_details od
on od."orderID" = o."orderID"
group by year, month
order by year, month)
select 
year,
sum(revenue) as revenue_jan_apr,
lag(sum(revenue)) over (order by year) as previous_year_revenue_jan_apr,
round(((sum(revenue) - lag(sum(revenue)) over (order by year)) / lag(sum(revenue)) over (order by year) * 100),2) as yoy_jan_apr
from revenue_by_year_month
where month between 1 and 4
and year in (2014,2015)
group by year
order by year;

-- BUSINESS INSIGHT:
-- Revenue increased by 120.72% in January - April 2015
-- compared to the same period in 2014
-- The comparison uses the equivalent four-month period
-- to avoid misleading conclusions from incomplete years 


-- TASK 4.A

-- Product Performance Analysis

select 
p."productID",
p."productName",
round(sum( od."quantity" * od."unitPrice" * (1-od."discount"))::numeric, 2) as revenue,
count(*) as order_lines,
sum(od."quantity") as total_quantity
from products p
join order_details od 
on od."productID" = p."productID"
group by p."productID" , p."productName" 
order by revenue desc;


-- TASK 4.B 
-- RANKING OF PRODUCTS, BASED ON PRODUCT PERFORMANCE ANALYSIS

with product_performance as (
select 
p."productID",
p."productName",
round(sum( od."quantity" * od."unitPrice" * (1-od."discount"))::numeric, 2) as revenue,
count(*) as order_lines,
sum(od."quantity") as total_quantity
from products p
join order_details od 
on od."productID" = p."productID"
group by p."productID" , p."productName" 
order by revenue desc )
select
"productID",
"productName",
revenue,
order_lines,
total_quantity,
round((revenue / sum(revenue) over() * 100),2) as product_share_percentage,
rank() over (order by revenue desc) as product_rank
from product_performance 
order by product_rank;


-- TASK 4.C 

with product_performance as (
select 
p."productID",
p."productName",
round(sum( od."quantity" * od."unitPrice" * (1-od."discount"))::numeric, 2) as revenue,
count(*) as order_lines,
sum(od."quantity") as total_quantity
from products p
join order_details od 
on od."productID" = p."productID"
group by p."productID" , p."productName" 
order by revenue desc ),
product_analysis as ( 
select
"productID",
"productName",
revenue,
order_lines,
total_quantity,
round((revenue / sum(revenue) over() * 100),2) as product_share_percentage,
row_number() over ( order by revenue desc, "productID") as product_row_number,
rank() over (order by revenue desc) as product_rank
from product_performance 
order by product_rank),
pareto_analysis as (
select 
"productID",
"productName",
product_row_number,
sum(revenue) over (
    order by revenue desc, "productID"
    rows between unbounded preceding and current row
) as cumulative_revenue,

(
    sum(revenue) over (
        order by revenue desc, "productID"
        rows between unbounded preceding and current row
    )
    / sum(revenue) over() * 100
) as cumulative_share_percentage,
product_rank
from product_analysis 
order by product_rank)
select 
min(product_row_number) as products_needed_for_80_pct
from pareto_analysis 
where cumulative_share_percentage >=80;


-- IMPORTANT: Select and execute the entire query,
-- starting from WITH product_performance AS
-- to the final semicolon.
-- CTEs cannot be executed separately.


-- BUSINESS INSIGHT
-- Côte de Blaye was the highest revenue-generating product.
-- contributing 11.17% of total sales revenue.
-- Camembert Pierrot had the highest quantity.
-- Raclette Courdavault had the highest number of order lines.
-- The top 36 out of 77 products ( 46.75 % of the portfolio)
-- generated approximately 80.2% of total_revenue
-- Pareto 80/20 distribution 
-- This indicates the revenue is concentrated among higher-performing  
-- products, although the classic 80/20 Pareto distribution is not observed.
-- These findings can help identify key products for sales monitoring
-- and inventory prioritization. 


-- TASK 5
-- CUSTOMER ANALYSIS 

-- AOV ( Average Order Value) = Total Revenue / Number of Orders 
-- Measures the average revenue generated per order

with customer_analysis as (
select 
c."customerID",
c."companyName",
count( distinct o."orderID") as total_orders,
round(sum(od."unitPrice" * od."quantity" * (1-od."discount"))::numeric, 2) as total_revenue,
round(round(sum(od."unitPrice" * od."quantity" * (1-od."discount"))::numeric, 2) / count( distinct o."orderID"),2) as Average_Order_Value,
rank () over( order by round(sum(od."unitPrice" * od."quantity" * (1-od."discount"))::numeric, 2) desc) as customer_rank
from customers c 
join orders o 
on o."customerID" = c."customerID"
join order_details od 
on od."orderID" = o."orderID" 
group by c."customerID" , c."companyName" 
order by total_revenue desc)
select 
"customerID",
"companyName",
total_orders,
total_revenue,
average_order_value,
customer_rank,
round(((total_revenue / sum(total_revenue) over()) * 100),2) as total_revenue_share
from customer_analysis 
order by total_revenue_share desc;


-- TASK 6 A
-- DISCOUNT ANALYSIS 

select 
round((od."discount" * 100)::numeric, 2) as discount_pct,
count( distinct o."orderID" ) as order_number,
sum(od."quantity") as total_quantity,
round(sum(od."unitPrice" * od."quantity" * (1-od."discount"))::numeric,2) as total_revenue
from order_details od
join orders o 
on o."orderID" = od."orderID" 
group by round((od."discount" * 100)::numeric, 2)
order by round(sum(od."unitPrice" * od."quantity" * (1-od."discount"))::numeric,2) desc;


-- BUSINESS INSIGHT:
-- Non-discounted sales generated the highest total revenue
-- However, the revenue differences alone do not establish
-- whether discounts increase sales volume 
-- Average quantity per order line is analyzed to assess
-- the relationship between discount levels and purchase volume 


-- TASK 6 B
-- DISCOUNT EFFECTIVENESS ANALYSIS 

select 
round((od."discount" * 100)::numeric, 2) as discount_pct,
count( distinct o."orderID" ) as order_number,
round(avg(od.quantity),2) as average_quantity_per_order_line,
sum(od."quantity") as total_quantity,
round(sum(od."unitPrice" * od."quantity" * (1-od."discount"))::numeric,2) as total_revenue
from order_details od
join orders o 
on o."orderID" = od."orderID" 
group by round((od."discount" * 100)::numeric, 2)
order by round(sum(od."unitPrice" * od."quantity" * (1-od."discount"))::numeric,2) desc;

-- BUSINESS INSIGHT:
-- Order lines with a 25% discount contain approximately 
-- 30% more units on average than non-discounted lines.
-- This suggests an association between higher discounts
-- and larger purchase quantities.
-- However, the analysis does not establish causation. 



-- TASK 7: 
-- EMPLOYEE SALES PERFORMANCE 

select 
e."employeeID",
e."employeeName",
e."title",
count(distinct o."orderID") as total_orders,
round(sum( od."unitPrice" * od."quantity" * (1-od."discount"))::numeric ,2) as total_revenue,
round(round(sum( od."unitPrice" * od."quantity" * (1-od."discount")):: numeric,2) / round(count(distinct o."orderID"),2),2) as average_order_value,
rank() over( order by sum( od."unitPrice" * od."quantity" * (1-od."discount")) desc ) as employee_rank
from employees e 
join orders o
on o."employeeID" = e."employeeID"
join order_details od 
on od."orderID" = o."orderID" 
group by e."employeeID", e."employeeName", e."title"
order by employee_rank asc;

-- BUSINESS INSIGHT:
-- Margaret  Peacock generated the highest total revenue 
-- among the analyzed employees , handling 156 orders.
-- Anne Dodsworth achieved the highest Average Order Value
-- among all analyzed employees.
-- This highlights the distinction between total sales revenue and average order value.





