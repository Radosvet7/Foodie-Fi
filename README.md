# Case Study #3 - Foodie-Fi

## B. Data Analysis Questions


### 1. How many customers has Foodie-Fi ever had?
```sql
SELECT Count(DISTINCT customer_id) AS total_customers
FROM   subscriptions
```
