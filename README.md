# Case Study #3 - Foodie-Fi

## B. Data Analysis Questions


### 1. How many customers has Foodie-Fi ever had?
```sql
SELECT Count(DISTINCT customer_id) AS total_customers
FROM   subscriptions
```
output 1

### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value?
```sql
SELECT Format(Dateadd(month, Datediff(month, 0, start_date), 0), 'yyyy-MM-dd')
       AS month
       ,
       Count(customer_id)
       AS customers
FROM   subscriptions
WHERE  plan_id = 0
GROUP  BY Dateadd(month, Datediff(month, 0, start_date), 0)
ORDER  BY Dateadd(month, Datediff(month, 0, start_date), 0)
```
output 2

### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name?
```sql
SELECT plan_name,
       Count (s.plan_id) AS event
FROM   subscriptions s
       JOIN plans p
         ON s.plan_id = p.plan_id
WHERE  Datepart(year, start_date) > 2020
GROUP  BY p.plan_name
```
output3

### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
```sql
DECLARE @total FLOAT = (SELECT Count(DISTINCT customer_id)
   FROM   subscriptions);

SELECT Count(customer_id)                AS churned_customers,
       Count(customer_id) / @total * 100 AS churn_rate
FROM   subscriptions
WHERE  plan_id = 4
```
outpu4

### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
```sql
WITH churned
     AS (SELECT customer_id,
                CASE
                  WHEN plan_id = 4
                       AND Lag(plan_id)
                             OVER (
                               partition BY customer_id
                               ORDER BY start_date) = 0 THEN 1
                  ELSE 0
                END AS chrn_cnt
         FROM   subscriptions)
SELECT Sum(chrn_cnt)
       AS
       churned_customers,
       Floor(Sum(chrn_cnt) / Cast(Count(DISTINCT customer_id) AS FLOAT) * 100)
       AS
       churn_prct
FROM   churned;
```
output5

### 6. What is the number and percentage of customer plans after their initial free trial?
```sql
DECLARE @total FLOAT = (SELECT Count(DISTINCT customer_id)
   FROM   subscriptions);

WITH cte
     AS (SELECT plan_id,
                Row_number()
                  OVER (
                    partition BY customer_id
                    ORDER BY start_date) AS plan_order
         FROM   subscriptions s
         WHERE  plan_id <> 0)
SELECT p.plan_name,
       Count(c.plan_id)                AS initial_plan_cnt,
       Count(c.plan_id) / @total * 100 AS plan_perc
FROM   plans p
       JOIN cte c
         ON p.plan_id = c.plan_id
WHERE  c.plan_order = 1
GROUP  BY p.plan_name
```

output6
