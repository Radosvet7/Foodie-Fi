--- B. Data Analysis Questions

--1.
SELECT COUNT(DISTINCT customer_id) as total_customers
FROM subscriptions

--2.
SELECT FORMAT(DATEADD(month, DATEDIFF(month, 0, start_date), 0), 'yyyy-MM-dd') as month,
COUNT(customer_id) as customers
FROM subscriptions
WHERE plan_id = 0
GROUP BY DATEADD(month, DATEDIFF(month, 0, start_date), 0)
ORDER BY DATEADD(month, DATEDIFF(month, 0, start_date), 0)

--3.
SELECT plan_name,
COUNT (s.plan_id) as event
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE DATEPART(YEAR, Start_date) > 2020
GROUP BY p.plan_name

--4.
DECLARE @total float = (SELECT COUNT(DISTINCT customer_id) FROM subscriptions);

SELECT COUNT(customer_id) as churned_customers,
COUNT(customer_id) / @total * 100 as churn_rate
FROM subscriptions
WHERE plan_id = 4


--5.
WITH churned AS(
SELECT
customer_id,
CASE WHEN plan_id = 4 AND LAG(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) = 0
THEN 1 ELSE 0
END as chrn_cnt
FROM subscriptions
)
SELECT 
  SUM(chrn_cnt) as churned_customers,
  FLOOR(SUM(chrn_cnt) / CAST(COUNT(DISTINCT customer_id) AS float) * 100) as churn_prct
FROM churned;

--6.
DECLARE @total float = (SELECT COUNT(DISTINCT customer_id) from subscriptions);

WITH CTE as (
select plan_id,
ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date) as plan_order
from subscriptions s
where plan_id<>0
)
SELECT p.plan_name,
count(c.plan_id) as initial_plan_cnt,
count(c.plan_id) / @total * 100  as plan_perc
FROM plans p
JOIN CTE c ON p.plan_id = c.plan_id
WHERE c.plan_order = 1
GROUP BY p.plan_name

--7. 
DECLARE @total float = (SELECT COUNT(DISTINCT customer_id) from subscriptions WHERE start_date<='2020-12-31');

WITH CTE as ( SELECT customer_id,
plan_id,
ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date DESC) as last_plan
FROM subscriptions
WHERE start_date<='2020-12-31')
SELECT p.plan_name,
COUNT ( c.customer_id ) as customer_cnt,
COUNT (c.customer_id) / @total * 100 as customer_perc
FROM cte c
JOIN plans p ON c.plan_id = p.plan_id AND c.last_plan=1
GROUP BY p.plan_name
ORDER BY COUNT (c.customer_id) DESC

--8.
-- Assuming trial is considered as upgradeable item
SELECT p.plan_name as [plan],
COUNT (s.customer_id) as customer_cnt
FROM subscriptions s
JOIN plans p  ON s.plan_id = p.plan_id and s.plan_id = 3 and start_date<='2020-12-31'
GROUP BY p.plan_name

-- Assuming upgraded from monthly to annual excluding trial->annual upgrade
WITH monthly_subs as(select customer_id,
plan_id,
start_date
from subscriptions 
where plan_id IN (1,2) and start_date<='2020-12-31'
),
annual_subs as(
select s.customer_id,
s.plan_id,
s.start_date
from subscriptions s
where s.plan_id = 3 and s.start_date<='2020-12-31')
SELECT p.plan_name as [plan],
COUNT (a.customer_id) as customer_cnt
from monthly_subs m
JOIN annual_subs a ON m.customer_id = a.customer_id
JOIN plans p ON p.plan_id = a.plan_id
GROUP BY p.plan_name

--9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
WITH annual_subs as(SELECT customer_id,
plan_id,
start_date as ap_start_date
FROM subscriptions
WHERE plan_id = 3),
customer_ap as(SELECT s.customer_id,
DATEDIFF(day, s.start_date, a.ap_start_date) as days_to_ap
FROM subscriptions s
JOIN annual_subs a ON s.customer_id = a.customer_id and s.plan_id=0)
SELECT AVG(days_to_ap) as 'Average days to annual plan'
FROM customer_ap

--10.
WITH trial_plan AS(
SELECT 
customer_id,
start_date AS join_date
FROM subscriptions
WHERE plan_id = 0
),
annual_plan AS(
SELECT 
customer_id,
start_date AS annual_start_date
FROM subscriptions
WHERE plan_id = 3
),
brackets AS(
SELECT 
tp.customer_id,
join_date,
annual_start_date,
DATEDIFF(DAY, join_date, annual_start_date)/30 + 1 AS bracket
FROM trial_plan tp
JOIN annual_plan ap ON tp.customer_id = ap.customer_id
)
SELECT 
CASE WHEN bracket = 1 THEN CONCAT(bracket-1, ' - ', bracket*30, ' days')
ELSE CONCAT((bracket-1)*30 + 1, ' - ', bracket*30, ' days')
END AS period,
COUNT(customer_id) AS total_customers,
CAST(AVG(DATEDIFF(DAY, join_date, annual_start_date)*1.0) AS decimal(5, 2)) AS average_days
FROM brackets
GROUP BY bracket

--11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH cte as(SELECT
CASE WHEN plan_id = 2 AND LEAD(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) = 1 
THEN 1
ELSE 0
END as downgraded
FROM subscriptions)
SELECT SUM(downgraded) as 'total downgraded'
FROM cte