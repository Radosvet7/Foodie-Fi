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

