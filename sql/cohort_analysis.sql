-- ============================================================
-- Cohort Retention Analysis
-- Cohort = month of customer's first purchase
-- Tracks what % of each cohort returned in subsequent months
-- ============================================================

-- Step 1: Find each customer's first purchase month
WITH first_purchase AS (
    SELECT
        c.customer_unique_id,
        DATE_TRUNC('month', MIN(f.order_purchase_timestamp))::DATE AS cohort_month
    FROM fact_orders f
    JOIN dim_customers c ON f.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
),

-- Step 2: All orders with cohort month attached
orders_with_cohort AS (
    SELECT
        c.customer_unique_id,
        fp.cohort_month,
        DATE_TRUNC('month', f.order_purchase_timestamp)::DATE AS order_month
    FROM fact_orders f
    JOIN dim_customers c ON f.customer_id = c.customer_id
    JOIN first_purchase fp ON c.customer_unique_id = fp.customer_unique_id
),

-- Step 3: Calculate months since first purchase
cohort_data AS (
    SELECT
        cohort_month,
        customer_unique_id,
        EXTRACT(YEAR FROM AGE(order_month, cohort_month)) * 12 +
        EXTRACT(MONTH FROM AGE(order_month, cohort_month)) AS months_since_first
    FROM orders_with_cohort
),

-- Step 4: Count distinct customers per cohort per month
cohort_counts AS (
    SELECT
        cohort_month,
        months_since_first,
        COUNT(DISTINCT customer_unique_id) AS customers
    FROM cohort_data
    GROUP BY cohort_month, months_since_first
),

-- Step 5: Cohort sizes (month 0 = all customers who joined that month)
cohort_sizes AS (
    SELECT cohort_month, customers AS cohort_size
    FROM cohort_counts
    WHERE months_since_first = 0
)

-- Step 6: Retention rate = returning customers / cohort size
SELECT
    cc.cohort_month,
    cc.months_since_first::INT           AS month_number,
    cs.cohort_size,
    cc.customers                          AS returning_customers,
    ROUND(cc.customers * 100.0 / cs.cohort_size, 1) AS retention_pct
FROM cohort_counts cc
JOIN cohort_sizes cs ON cc.cohort_month = cs.cohort_month
WHERE cc.cohort_month >= '2017-01-01'   -- focus on months with full data
  AND cc.cohort_month <= '2018-08-01'
  AND cc.months_since_first <= 6        -- track up to 6 months out
ORDER BY cc.cohort_month, cc.months_since_first;
