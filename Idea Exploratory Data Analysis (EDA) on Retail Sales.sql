/*create Database Oasis_infobyte;*/
/*Idea: Exploratory Data Analysis (EDA) on Retail Sales Data
Description:
In this project, dataset containing information about retail sales. The goal is
to perform exploratory data analysis (EDA) to uncover patterns, trends, and insights that can
help the retail business make informed decisions.*/

--- Checking Null in dataset for cleaning purpose.
Select * from retail_sales_datasetC ;
Select * from retail_sales_datasetC
WHERE NULL IN (Transaction_ID,Customer_ID, Gender, Product_Category);

---Top 10 Customer with highest Sales
Select top 10 Customer_ID,max(Total_Amount) as tranx from retail_sales_datasetC
group by Customer_ID
order by tranx desc;

/*Total Amount sold by Product Category/ Top Product Categories*/
Select Product_Category,Sum(Total_Amount) as Amount,count(*) as number_of_orders
from retail_sales_datasetc
group by Product_Category
order by Amount desc;


/* Maximum and Minimum MRP in each product category*/
Select Product_Category,max(Price_per_Unit) as high_mrp_product,min(Price_per_Unit) as lowest_mrp_product
from retail_sales_datasetc
group by Product_Category



/*Oldest and Youngest Person in each gender */
Select Gender,max(Age) as oldest_person_age,min(Age) youngest_person_age from retail_sales_datasetC
group by Gender;

/*Maximum Shopping in different age group and Gender */

SELECT 
    Gender,
    SUM(CASE WHEN Age >= 18 AND Age <= 30 THEN Total_Amount ELSE 0 END) AS Amount__age_group_18_30,
    COUNT(CASE WHEN Age >= 18 AND Age <= 30 THEN 1 ELSE NULL END) AS person_age_group_18_30,
	SUM(CASE WHEN Age > 30 AND Age <= 45 THEN Total_Amount ELSE 0 END) AS Amount__age_group_30_45,
    COUNT(CASE WHEN Age > 30 AND Age <= 45 THEN 1 ELSE NULL END) AS person_age_group_30_45,
	SUM(CASE WHEN Age > 45 AND Age <= 55 THEN Total_Amount ELSE 0 END) AS Amount__age_group_45_55,
    COUNT(CASE WHEN Age > 45 AND Age <= 55 THEN 1 ELSE NULL END) AS person_age_group_45_55,
	SUM(CASE WHEN Age >55 THEN Total_Amount ELSE 0 END) AS Amount_age_group_55_above,
    COUNT(CASE WHEN Age > 55  THEN 1 ELSE NULL END) AS person_age_group_55_above
FROM 
    retail_sales_datasetC
GROUP BY 
    Gender;

-- Gender-based Spending Analysis
SELECT gender, SUM(total_amount) AS total_spent, COUNT(*) AS total_purchases
FROM retail_sales_datasetC
GROUP BY gender
ORDER BY total_spent DESC;
	

/*First order Date and Last order Date ,Amount in each Product_Category*/
with cte as (
Select Product_Category,total_Amount,date,rank()over(partition by Product_Category order by Date asc) as First_order
,rank()over(partition by Product_Category order by Date desc) as Latest_order
from retail_sales_datasetc)

Select Product_Category,Total_amount,Date from cte where First_order=1 or Latest_order=1;


/*Quatarly Sales Growth trend*/
 with cte as
 (SELECT
    YEAR(date) AS year,
    CASE 
when month(date) in (1,2,3) then  'Q1'
when month(date) in (4,5,6) then 'Q2'
when month(date) in (7,8,9) then 'Q3'
when month(date) in (10,11,12) then  'Q4'
    END AS quarter,
    SUM(total_amount) AS total_sales
FROM 
    retail_sales_datasetC
GROUP BY 
    YEAR(date), 
    CASE 
        when month(date) in (1,2,3) then  'Q1'
when month(date) in (4,5,6) then 'Q2'
when month(date) in (7,8,9) then 'Q3'
when month(date) in (10,11,12) then  'Q4'
    END
)
	SELECT 
    year,
    quarter,
    total_sales,
    LAG(total_sales) OVER (partition by year ORDER BY year, quarter) AS prev_quarter_sales,
    (total_sales - LAG(total_sales) OVER (partition by year ORDER BY year, quarter))*100.00 / total_sales AS quarterly_growth_rate
FROM 
    cte
ORDER BY 
    year, 
    quarter;


	/* Aggregate total sales amount by month and year /Monthly Sales Trends */
SELECT 
    year(date)as year,MONTH(date) as month, 
    SUM(total_amount) AS Total_Sales
FROM 
    retail_sales_datasetc
GROUP BY 
    year(date),MONTH(date)
ORDER BY 
    year(date),MONTH(date);

-- Calculate 7-day rolling average of total sales
SELECT 
    date, 
    Total_Sales,
    AVG(Total_Sales) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS Rolling_Avg_7_Days
FROM (
    SELECT 
        date, 
        SUM(total_amount) AS Total_Sales
    FROM 
        retail_sales_datasetc
    GROUP BY 
        date
) AS SalesData
ORDER BY 
    date;

/* Sales growth rate by each year per month*/
with cte as 
(SELECT 
    year(date)as year,MONTH(date) as month, 
    SUM(total_amount) AS Total_Sales
FROM 
    retail_sales_datasetc
GROUP BY 
    year(date),MONTH(date)
)
,rte as (
select year,month,total_Sales,lag(total_Sales)over(partition by year order by month) as next_sales from cte)

select year,month,((total_sales-next_sales)*100.0)/total_Sales as sales_growth_rate from rte
;



/*'Descriptive Statistics: Calculate basic statistics (mean, median, mode, standard deviation)*/



WITH mode_cte AS (
    SELECT 
        Total_Amount AS mode_value, 
        COUNT(*) AS occurrence 
    FROM 
        retail_sales_datasetC 
    GROUP BY 
        Total_Amount
),
mode_value AS (
    SELECT 
        TOP 1 mode_value 
    FROM 
        mode_cte 
    ORDER BY 
        occurrence DESC 
),
median_cte AS (
    SELECT 
        total_amount,
        ROW_NUMBER() OVER (ORDER BY total_amount) AS row_num,
        COUNT(*) OVER () AS number 
    FROM 
        retail_sales_datasetC
),
median_value AS (
    SELECT 
        AVG(total_amount) AS median 
    FROM 
        median_cte
    WHERE 
        row_num IN ((number + 1) / 2, (number + 2) / 2)
),
standard_deviation AS
(SELECT 
    STDEV(total_amount) as standard_deviation_value
FROM 
    retail_sales_datasetC),
Sd_value AS
(
select standard_deviation_value from standard_deviation)

SELECT 
    (SELECT AVG(total_Amount) FROM retail_sales_datasetC) AS mean,
    (SELECT median FROM median_value) AS median,
    (SELECT mode_value FROM mode_value) AS mode,
	(SELECT standard_deviation_value FROM Sd_value) as SD;




