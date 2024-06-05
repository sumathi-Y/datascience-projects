# AMAZON SALES ANALYSIS

#Data Wrangling: inspection of data is done to make sure NULL values and missing values are detected

CREATE DATABASE IF NOT EXISTS amazon;
CREATE TABLE IF NOT EXISTS amazon_sales(
	Invoice_ID VARCHAR(30) NOT NULL PRIMARY KEY,
    Branch VARCHAR(5) NOT NULL,
    City VARCHAR(30) NOT NULL,
    Customer_type VARCHAR(30) NOT NULL,
    Gender VARCHAR(10) NOT NULL,
    Product_line VARCHAR(100) NOT NULL,
    Unit_price DECIMAL(10, 2) NOT NULL,
    Quantity INT NOT NULL,
    Tax_5_Percentage FLOAT(6, 4) NOT NULL,
    Total DECIMAL(10, 2) NOT NULL,
    Date DATETIME NOT NULL,
    Time TIME NOT NULL,
    Payment VARCHAR(30) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_percentage FLOAT(11, 9),
    gross_income DECIMAL(10, 2),
    Rating FLOAT(2, 1)
);
use amazon;
SELECT * FROM amazon_sales;

#Feature Engineering: This will help us generate some new columns from existing ones.
SELECT
 Time,
 (CASE
 WHEN `Time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
 WHEN `Time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
 ELSE "Evening"
 END) AS time_of_day
FROM amazon_sales;

-- Add time_of_day column
ALTER TABLE amazon_sales ADD COLUMN time_of_day VARCHAR(20);
UPDATE amazon_sales
SET time_of_day = (
 CASE
  WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);

SELECT time_of_day from amazon_sales;

-- Add day_name column
SELECT
 Date,
 DAYNAME(Date)
FROM amazon_sales;
ALTER TABLE amazon_sales ADD COLUMN day_name VARCHAR(10);
UPDATE amazon_sales
SET day_name = DAYNAME(date);
SELECT * FROM amazon_sales;

-- Add month_name column
SELECT
 date,
 MONTHNAME(date) 
FROM amazon_sales;
ALTER TABLE amazon_sales ADD COLUMN month_name VARCHAR(10);
UPDATE amazon_sales
SET month_name = MONTHNAME(date);
SELECT * FROM amazon_sales;

#--Exploratory Data Analysis (EDA): 

#1.What is the count of distinct cities in the dataset?
SELECT 
DISTINCT city,
count(city) as count_dis_cities
FROM amazon_sales
GROUP BY city                     #ouput- There are 3 distinct cities and there counts are Yangon(340),Mandalay(332), Naypyitaw(328)
ORDER BY count_dis_cities DESC;       

#2.For each branch, what is the corresponding city?
SELECT 
DISTINCT city,
Branch
FROM amazon_sales
ORDER BY branch;                      #ouput - A:Yangon; B:Mandalay; C:Naypyitaw  


#PRODUCT ANALYSIS

#3.What is the count of distinct product lines in the dataset?
SELECT 
COUNT(DISTINCT Product_line) as distinct_product
FROM amazon_sales;                    #output- 6 distinct product_line

                          
#SALES ANALYSIS

#5.Which product line has the highest sales?
SELECT Product_line,
count(Product_line) as Highest_sales
FROM amazon_sales
GROUP BY Product_line
ORDER BY Highest_sales desc;     #output- Fashion accessories(178)
                                 #      - Health and beauty(152)
    

#6.How much revenue is generated each month?
SELECT 
 month_name as Month,
 ROUND(SUM(Total),2) as Total_revenue
FROM amazon_sales
GROUP BY month_name
ORDER BY Total_revenue DESC;     #output- Jan(116292); Mar(109456); Feb(97219);

#7.In which month did the cost of goods sold reach its peak?
SELECT
 month_name AS month,
 ROUND(SUM(cogs),2) AS cogs
FROM amazon_sales
GROUP BY month_name 
ORDER BY cogs desc;             #output- Jan(110754);Mar(104243);Feb(92590);

#8.Which product line generated the highest revenue?
SELECT
 product_line,
 ROUND(SUM(total),2) as total_revenue
FROM amazon_sales
GROUP BY product_line
ORDER BY total_revenue DESC; 

#9.In which city was the highest revenue recorded?
SELECT
 city,
 ROUND(SUM(total),2) as total_revenue
FROM amazon_sales
GROUP BY city
ORDER BY total_revenue DESC;      #output- 'Naypyitaw', '110568.71'


#10.Which product line incurred the highest Value Added Tax?
SELECT
 product_line,
 ROUND(AVG(Tax_5_percentage),2) as highest_VAT
FROM amazon_sales
GROUP BY product_line
ORDER BY highest_VAT DESC;          #output-  'Home and lifestyle', '16.03'

#11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
SELECT 
 AVG(quantity) AS avg_qnty
FROM amazon_sales;                 #output-  avg_qnty: '5.5100'

SELECT
 product_line,
 CASE
  WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM amazon_sales                     #output- none of the product_line above avg 6
GROUP BY product_line;                #so it is remarked as Bad

#12.Identify the branch that exceeded the average number of products sold.
SELECT 
 branch, 
 SUM(quantity) AS quantity
FROM amazon_sales                   #output- 'A', '1859';'C', '1831';'B', '1820'
GROUP BY branch 												
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM amazon_sales);													
             
#13.Which product line is most frequently associated with each gender?
SELECT
 product_line,
    gender,
    COUNT(gender) AS total_count
FROM amazon_sales
GROUP BY gender, product_line
ORDER BY total_count DESC;       #output- 'Fashion accessories', 'Female', '96'

#14.Calculate the average rating for each product line.
SELECT 
 product_line,
  ROUND(AVG(rating),2) as Avg_rating
FROM amazon_sales
GROUP BY product_line
ORDER BY avg_rating DESC;         #output- 'Food and beverages', '7.11'

#15.Count the sales occurrences for each time of day on every weekday.
SELECT 
 time_of_day,
  count(*) AS Time_sales
FROM amazon_sales
WHERE day_name = "sunday"
GROUP BY time_of_day
ORDER BY Time_sales DESC;        #output- sunday-evening & afternoon sale is high

SELECT 
 time_of_day,
  count(*) AS Time_sales
FROM amazon_sales
WHERE day_name = "wednesday"
GROUP BY time_of_day
ORDER BY Time_sales DESC;       #output- wednesday-afternoon & evening sale is high

SELECT 
 time_of_day,
  count(*) AS Time_sales
FROM amazon_sales
WHERE day_name = "saturday"
GROUP BY time_of_day
ORDER BY Time_sales DESC;        #output- sunday-evening sale is high

SELECT 
 month_name,day_name,time_of_day, 
 count(day_name) as day_sales
FROM amazon_sales
GROUP BY month_name,day_name,time_of_day
ORDER BY day_sales DESC;        #output- 'January', 'Saturday', 'Evening', '30'
								#overall view- sale is less in the month of February
                                #In this 3months all days morning time the sale is less 

#16.Identify the customer type contributing the highest revenue.
SELECT
 Customer_type,
 round(SUM(total),2) AS total_revenue
FROM amazon_sales
GROUP BY customer_type
ORDER BY total_revenue DESC;     #output- 'Member', '164223.44'

#17.Determine the city with the highest VAT percentage.
SELECT
 city,
    ROUND(AVG(Tax_5_percentage), 2) AS avg_tax_pct
FROM amazon_sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;     #output- 'Naypyitaw', '16.05'


#18.Identify the customer type with the highest VAT payments.
SELECT
 Customer_type,
    ROUND(AVG(Tax_5_percentage), 2) AS avg_tax_pct
FROM amazon_sales
GROUP BY customer_type 
ORDER BY avg_tax_pct DESC;         #output- 'Member', '15.61'

#20.What is the count of distinct payment methods in the dataset?
SELECT
 COUNT(DISTINCT payment) as count_dis_payment
FROM amazon_sales;               #output- There are 3 distinct payment methods. 

#4.Which payment method occurs most frequently?
SELECT
DISTINCT Payment, 
count(payment) as freq_payment
FROM amazon_sales 
GROUP BY payment;          #ouput - Ewallet(345);Cash(344) is most frequently used payment method
                           #      - credit card(311) is less frequently used
                           
# CUSTOMER ANALYSIS

#19.What is the count of distinct customer types in the dataset?
SELECT
 COUNT(DISTINCT customer_type) 
 as count_dis_customer
FROM amazon_sales;                   #output- There are 2 distinct customer types
                        
#21.Which customer type occurs most frequently?
SELECT
 customer_type,
 count(*) as count
FROM amazon_sales
GROUP BY customer_type
ORDER BY count DESC;                 #output- more or less the same

#22.Identify the customer type with the highest purchase frequency.
SELECT
 customer_type,
 AVG(Quantity) as Highest_purchase
FROM amazon_sales
GROUP BY customer_type;               #output- more or less the same

#23.Determine the predominant gender among customers.
SELECT 
 gender,
 count(*) as gender_count
FROM amazon_sales
GROUP BY gender
ORDER BY gender_count DESC;             #output- more or less the same

#24.Examine the distribution of genders within each branch.
SELECT 
 branch, gender,
 count(*) as gender_count
FROM amazon_sales                        #output A branch: Male-179 & Female-161
GROUP BY branch,gender                   #output B branch: Male-170 & Female-162
order by gender_count DESC;              #output C branch: Female-178 & Male-150

#25.Identify the time of day when customers provide the most ratings.
SELECT
 time_of_day, 
 ROUND(AVG(rating),2) as avg_rating
FROM amazon_sales
GROUP BY time_of_day                    #output- Rating according to the time of the day
ORDER BY avg_rating DESC;               # The avg rating is around 7

#26.Determine the time of day with the highest customer ratings for each branch.
SELECT
 branch,time_of_day, 
 ROUND(AVG(rating),2) as avg_rating
FROM amazon_sales
GROUP BY time_of_day,branch              #output- Rating According to the time of day for each branch 
ORDER BY avg_rating DESC;                # A-branch has the the highest rating of 7.19 in the afternoon

#27.Identify the day of the week with the highest average ratings.
SELECT
 day_name, 
 ROUND(AVG(rating),2) as avg_rating
FROM amazon_sales
GROUP BY day_name                #output- Rating According to the weekdays
ORDER BY avg_rating DESC;        # Monday has the highest average rating of 7.15

#28.Determine the day of the week with the highest average ratings for each branch.
SELECT
 branch,day_name, 
 ROUND(AVG(rating),2) as avg_rating
FROM amazon_sales
GROUP BY branch,day_name         #output- Rating according to the weekday for each branch
ORDER BY avg_rating DESC;        # B-branch on Monday has the highest average rating of 7.34

