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

