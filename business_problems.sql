-- Business Questions on Walmart_db


-- Q1 What are the different payment methods, and how many transactions and items were sold with each method?
select
	distinct payment_method,
	count(payment_method) as transactions,
	sum(quantity) as items_sold
from walmart
group by 1
order by transactions desc;


-- Q2 Which category received the highest average rating in each branch?

select * 
from
	(select 
		branch,
		category,
		avg(rating) as avg_rating,
		rank() over(partition by branch order by avg(rating) desc) as highest_avg_rating_by_branch 
	from walmart
	group by 1,2
	order by highest_avg_rating_by_branch asc
	)
where highest_avg_rating_by_branch = 1;


-- Q3 Which is the busiest day of the week for each branch based on transaction volume?

select * from
(
select 
	branch,
	to_char(date, 'Day') as busiest_day,
	count(invoice_id),
	rank() over(partition by branch order by count(*) desc) as ranks
from walmart
group by 1,2
)
where ranks = 1;

-- Q4 How many items were sold through each payment method?

select
	payment_method,
	sum(quantity) as items_sold
from walmart
group by 1;


-- Q5 What are the average, minimum, and maximum ratings for each category in each city?

select 
	city,
	category,
	avg(rating),
	min(rating),
	max(rating)
from walmart
group by city,2;


-- Q6 What is the total profit for each category, ranked from highest to lowest?

select 
	category,
	sum(total) as total_revenue,
	sum(total*profit_margin) as total_profit
from walmart
group by 1
order by 3 desc;


--  Q7 What is the most frequently used payment method in each branch?

select * from
(select 
	branch,
	payment_method,
	count(*) as total_transactions,
	rank() over(partition by branch order by count(*) desc) as rnk
from walmart
group by 1,2
)
where rnk = 1;


--  Q8 How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?

select 
	branch,
	count(*) as transactions,
	case
		when time between '06:00:00' and '12:00:00' then 'Morning Shift'
		when time between '12:00:01' and '17:00:00' then 'Afternoon Shift'
		else 'Evening Shift'
	end as shift_timing
from walmart
group by 1,3
order by transactions desc;


-- Q9 Which branches experienced the largest decrease in revenue as compared to the last year?
-- Assume the current year - 2023


with revenue_2022
as
(select 
	branch,
	sum(total) as total_revenue_2022
from walmart
where extract(year from date)=2022
group by 1
),

revenue_2023 
as
(select 
	branch,
	sum(total) as total_revenue_2023
from walmart
where extract(year from date)=2023
group by 1
)

select
	curr_year.branch,
	total_revenue_2022 - total_revenue_2023 as revenue_decrease,
	round(((total_revenue_2022 - total_revenue_2023)::numeric/(total_revenue_2022)::numeric)*100 , 2) as percentage_decrease
	
from revenue_2022 as last_year
join revenue_2023 as curr_year
	on last_year.branch = curr_year.branch
where total_revenue_2022 > total_revenue_2023
order by 2 desc
limit 10;