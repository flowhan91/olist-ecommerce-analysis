-- ============================================================
-- Delivery Speed vs Customer Satisfaction
-- Key business question: does faster delivery = happier customers?
-- ============================================================

SELECT
    CASE
        WHEN delivery_days <= 5  THEN '1. Under 5 days'
        WHEN delivery_days <= 10 THEN '2. 6-10 days'
        WHEN delivery_days <= 20 THEN '3. 11-20 days'
        ELSE                          '4. Over 20 days'
    END                                         AS delivery_bucket,
    COUNT(*)                                    AS order_count,
    ROUND(AVG(review_score), 2)                 AS avg_review_score,
    ROUND(AVG(satisfied) * 100, 1)              AS satisfaction_pct,
    ROUND(AVG(total_payment), 2)                AS avg_order_value_brl
FROM fact_orders
WHERE review_score IS NOT NULL
  AND delivery_days IS NOT NULL
GROUP BY delivery_bucket
ORDER BY delivery_bucket;
