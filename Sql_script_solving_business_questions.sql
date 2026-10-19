SELECT * FROM walmart limit 10;


-- Count total records
SELECT COUNT(*) FROM walmart;


-- Count payment methods and number of transactions by payment method
SELECT 
    payment_method,
    COUNT(*) AS no_payments
FROM walmart
GROUP BY payment_method;


-- Count distinct branches
SELECT COUNT(DISTINCT branch) FROM walmart;


-- Business Problem Q1: Find different payment methods, number of transactions, and quantity sold by payment method
SELECT 
    payment_method,
    COUNT(*) AS no_payments,
    SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;



-- ********** Q2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating
SELECT branch, category, round(avg_rating,2)
FROM (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS `rank`
    FROM walmart
    GROUP BY branch, category
) AS ranked
WHERE `rank` = 1;



-- Q3: Identify the busiest day for each branch based on the number of transactions
select branch, day, no_of_transactions
from(
	select branch,
		dayname(date) as "day",
        count(*) as no_of_transactions,
        dense_rank() over(partition by branch order by count(*) desc) as rankk
	from walmart
	group by branch,day
) tble
where rankk=1;



-- Q4: Calculate the total quantity of items sold per payment method
select payment_method, sum(quantity) as quantity_sold
from walmart
group by payment_method;



-- Q5: Determine the average, minimum, and maximum rating of categories for each city
select city, 
		category,
		round(avg(rating),2) as average_rating,
		min(rating) as min_rating,
        max(rating) as max_rating
from walmart
group by city, category
order by average_rating desc;



-- Q6: Calculate the total profit for each category
select category, 
		round(sum(unit_price * quantity * profit_margin ),2) as total_profit,
        round(sum(unit_price * quantity * profit_margin )/(select sum(unit_price * quantity * profit_margin) from walmart)*100,2) as profit_percentage
from walmart
group by category
order by total_profit desc;

-- OR ----
select category, 
		round( sum(total * profit_margin ) ,2) as total_profit
from walmart
group by category;




-- Q7: Determine the most common payment method for each branch
WITH cte AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rankk
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method AS preferred_payment_method
FROM cte
WHERE rankk = 1;



-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts for every branch with their 
-- count and order the result in decreasing order by the number_of_shifts per shift per branch
select branch,
case 
	when hour(time) <12 then 'Morning shift'
	when hour(time) between 12 and 17 then "Afternoon shift"
    else 'Evening shift'
end as shift,
count(*) as number_of_shifts
from walmart
group by branch,shift
order by branch, number_of_shifts desc;




-- ******* Q9: Identify the 5 branches with the highest revenue decrease ratio from 2022 to 2023 

-- 2022 revenue
with revenue_2022 as (
	select branch,
		sum(total) as revenue
	from walmart
	where year(date) = "2022"
	group by branch
),
revenue_2023 as (
	select branch,
		sum(total) as revenue
	from walmart
	where year(date) = "2023"
	group by branch
)
select last_year.branch,
		last_year.revenue as last_year_revenue,
        curr_year.revenue as current_year_revenue, 
        round(((last_year.revenue-curr_year.revenue)/last_year.revenue)*100,2) as revenue_decrease_ratio
from revenue_2022 as last_year
join revenue_2023 as curr_year
on last_year.branch = curr_year.branch
where last_year.revenue>curr_year.revenue
order by revenue_decrease_ratio desc
limit 5;

