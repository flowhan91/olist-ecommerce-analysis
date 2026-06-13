-- ============================================================
-- RFM Analysis — Customer Segmentation
-- Recency:  days since last order (lower = better)
-- Frequency: number of orders placed
-- Monetary:  total amount spent
-- ============================================================

-- Step 1: Calculate raw RFM values per customer
WITH rfm_base AS (
    SELECT
        c.customer_unique_id,
        MAX(f.order_purchase_timestamp)                          AS last_order_date,
        DATE '2018-10-01' - MAX(f.order_purchase_timestamp)::DATE AS recency_days,
        COUNT(f.order_id)                                        AS frequency,
        SUM(f.total_payment)                                     AS monetary
    FROM fact_orders f
    JOIN dim_customers c ON f.customer_id = c.customer_id
    WHERE f.total_payment > 0
    GROUP BY c.customer_unique_id
),

-- Step 2: Score each metric 1-5 using quintiles
rfm_scores AS (
    SELECT
        customer_unique_id,
        recency_days,
        frequency,
        ROUND(monetary::NUMERIC, 2) AS monetary,
        NTILE(5) OVER (ORDER BY recency_days DESC)  AS r_score,  -- lower recency = higher score
        NTILE(5) OVER (ORDER BY frequency ASC)      AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC)       AS m_score
    FROM rfm_base
),

-- Step 3: Combine scores and assign segment labels
rfm_segments AS (
    SELECT
        customer_unique_id,
        recency_days,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,
        (r_score + f_score + m_score) AS rfm_total,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3                   THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score <= 2                   THEN 'New Customers'
            WHEN r_score >= 3 AND f_score <= 2 AND m_score >= 3  THEN 'Potential Loyalists'
            WHEN r_score <= 2 AND f_score >= 3                   THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2 AND m_score >= 3  THEN 'Cant Lose Them'
            WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2  THEN 'Lost'
            ELSE 'Need Attention'
        END AS segment
    FROM rfm_scores
)

-- Step 4: Segment summary
SELECT
    segment,
    COUNT(*)                        AS customer_count,
    ROUND(AVG(recency_days), 1)     AS avg_recency_days,
    ROUND(AVG(frequency), 2)        AS avg_frequency,
    ROUND(AVG(monetary), 2)         AS avg_monetary_brl,
    ROUND(SUM(monetary), 2)         AS total_revenue_brl
FROM rfm_segments
GROUP BY segment
ORDER BY total_revenue_brl DESC;
