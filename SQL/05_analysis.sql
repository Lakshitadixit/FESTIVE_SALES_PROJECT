
-- =========================================================
-- Festive vs Non-Festive Coverage
-- =========================================================

SELECT
    CASE 
        WHEN fw.order_id IS NOT NULL THEN 'Festive'
        ELSE 'Non-Festive'
    END AS sales_period,
    COUNT(DISTINCT sf.order_id) AS total_orders,
    ROUND(SUM(sf.final_amount), 2) AS total_revenue,
    ROUND(AVG(sf.final_amount), 2) AS avg_order_value
FROM sales_fact sf
LEFT JOIN festival_window fw
    ON sf.order_id = fw.order_id
GROUP BY sales_period
ORDER BY sales_period;



-- =========================================================
-- Revenue Contribution by Festival
-- =========================================================

SELECT
    festival_name,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(final_amount), 2) AS total_revenue,
    ROUND(
        SUM(final_amount) * 100.0 /
        SUM(SUM(final_amount)) OVER (),
        2
    ) AS revenue_share_pct
FROM festival_window
GROUP BY festival_name
ORDER BY total_revenue DESC;



-- =========================================================
-- Sales Trend by Festival Proximity
-- =========================================================

SELECT
    CASE
        WHEN days_to_festival = 0 THEN 'Festival Day'
        WHEN days_to_festival BETWEEN 1 AND 7 THEN 'Peak Pre-Festival'
        WHEN days_to_festival BETWEEN 8 AND 15 THEN 'Early Pre-Festival'
    END AS festival_period,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(final_amount), 2) AS total_revenue,
    ROUND(AVG(final_amount), 2) AS avg_order_value
FROM festival_window
GROUP BY festival_period
ORDER BY
    CASE
        WHEN festival_period = 'Early Pre-Festival' THEN 1
        WHEN festival_period = 'Peak Pre-Festival' THEN 2
        WHEN festival_period = 'Festival Day' THEN 3
    END;




-- =========================================================
-- Discount Effectiveness During Festivals
-- =========================================================

SELECT
    CASE
        WHEN sf.discount_pct = 0 THEN 'No Discount'
        WHEN sf.discount_pct <= 10 THEN 'Low Discount (≤10%)'
        WHEN sf.discount_pct <= 30 THEN 'Medium Discount (11–30%)'
        ELSE 'High Discount (>30%)'
    END AS discount_bucket,
    COUNT(DISTINCT sf.order_id) AS total_orders,
    ROUND(AVG(sf.final_amount), 2) AS avg_order_value,
    ROUND(SUM(sf.final_amount), 2) AS total_revenue
FROM sales_fact sf
JOIN festival_window fw
  ON sf.order_id = fw.order_id
GROUP BY discount_bucket
ORDER BY total_orders DESC;



-- =========================================================
-- Category Performance During Festivals
-- =========================================================

SELECT
    sf.category,
    COUNT(DISTINCT sf.order_id) AS total_orders,
    ROUND(SUM(sf.final_amount), 2) AS total_revenue,
    ROUND(AVG(sf.final_amount), 2) AS avg_order_value
FROM sales_fact sf
JOIN festival_window fw
  ON sf.order_id = fw.order_id
GROUP BY sf.category
ORDER BY total_revenue DESC;



-- =========================================================
-- State-wise Festival Performance
-- =========================================================

SELECT
    sf.state,
    fw.festival_name,
    COUNT(DISTINCT sf.order_id) AS total_orders,
    ROUND(SUM(sf.final_amount), 2) AS total_revenue
FROM sales_fact sf
JOIN festival_window fw
  ON sf.order_id = fw.order_id
GROUP BY sf.state, fw.festival_name
ORDER BY total_revenue DESC;



-- =========================================================
-- Region × Festival Impact
-- =========================================================

SELECT
    sf.region,
    fw.festival_name,
    COUNT(DISTINCT sf.order_id) AS total_orders,
    ROUND(SUM(sf.final_amount), 2) AS total_revenue
FROM sales_fact sf
JOIN festival_window fw
  ON sf.order_id = fw.order_id
GROUP BY sf.region, fw.festival_name
ORDER BY total_revenue DESC;




-- =========================================================
-- Sales Uplift: Festive vs Non-Festive Performance
-- =========================================================

WITH order_labeled AS (
    SELECT 
        sf.order_id,
        sf.order_date,
        sf.final_amount,
        sf.discount_pct,
        CASE 
            WHEN fw.order_id IS NOT NULL THEN 'Festive'
            ELSE 'Non-Festive'
        END AS sales_period
    FROM sales_fact sf
    LEFT JOIN festival_window fw
        ON sf.order_id = fw.order_id
),

daily_metrics AS (
    SELECT
        order_date,
        sales_period,
        COUNT(order_id) AS daily_orders,
        SUM(final_amount) AS daily_revenue,
        AVG(final_amount) AS daily_aov,
        AVG(discount_pct) AS avg_daily_discount
    FROM order_labeled
    GROUP BY order_date, sales_period
),

period_summary AS (
    SELECT
        sales_period,
        COUNT(DISTINCT order_date) AS active_days,
        ROUND(SUM(daily_orders) / COUNT(DISTINCT order_date), 2) AS avg_daily_orders,
        ROUND(SUM(daily_revenue) / COUNT(DISTINCT order_date), 2) AS avg_daily_revenue,
        ROUND(AVG(daily_aov), 2) AS avg_daily_aov,
        ROUND(AVG(avg_daily_discount), 2) AS avg_daily_discount
    FROM daily_metrics
    GROUP BY sales_period
),

pivoted AS (
    SELECT
        MAX(CASE WHEN sales_period = 'Festive' THEN avg_daily_orders END) AS festive_orders,
        MAX(CASE WHEN sales_period = 'Non-Festive' THEN avg_daily_orders END) AS non_festive_orders,

        MAX(CASE WHEN sales_period = 'Festive' THEN avg_daily_revenue END) AS festive_revenue,
        MAX(CASE WHEN sales_period = 'Non-Festive' THEN avg_daily_revenue END) AS non_festive_revenue,

        MAX(CASE WHEN sales_period = 'Festive' THEN avg_daily_aov END) AS festive_aov,
        MAX(CASE WHEN sales_period = 'Non-Festive' THEN avg_daily_aov END) AS non_festive_aov,

        MAX(CASE WHEN sales_period = 'Festive' THEN avg_daily_discount END) AS festive_discount,
        MAX(CASE WHEN sales_period = 'Non-Festive' THEN avg_daily_discount END) AS non_festive_discount
    FROM period_summary
)

SELECT
    ROUND(
        (festive_orders - non_festive_orders) * 100.0 / non_festive_orders,
        2
    ) AS orders_uplift_pct,

    ROUND(
        (festive_revenue - non_festive_revenue) * 100.0 / non_festive_revenue,
        2
    ) AS revenue_uplift_pct,

    ROUND(
        (festive_aov - non_festive_aov) * 100.0 / non_festive_aov,
        2
    ) AS aov_uplift_pct,

    ROUND(
        festive_discount - non_festive_discount,
        2
    ) AS discount_difference_pct
FROM pivoted;


-- =========================================================
-- Category-wise Uplift: Festive vs Non-Festive Performance
-- =========================================================


WITH order_labeled AS (
    SELECT 
        sf.order_id,
        sf.order_date,
        sf.category,
        sf.final_amount,
        CASE 
            WHEN fw.order_id IS NOT NULL THEN 'Festive'
            ELSE 'Non Festive'
        END AS sales_period
    FROM sales_fact sf
    LEFT JOIN festival_window fw
        ON sf.order_id = fw.order_id
),

daily_category_metrics AS (
    SELECT
        order_date,
        category,
        sales_period,
        AVG(final_amount) AS daily_aov
    FROM order_labeled
    GROUP BY order_date, category, sales_period
),

category_period_summary AS (
    SELECT
        category,
        sales_period,
        ROUND(AVG(daily_aov), 2) AS avg_daily_aov
    FROM daily_category_metrics
    GROUP BY category, sales_period
),

category_pivot AS (
    SELECT
        category,
        MAX(CASE WHEN sales_period = 'Festive' THEN avg_daily_aov END) AS festive_aov,
        MAX(CASE WHEN sales_period = 'Non Festive' THEN avg_daily_aov END) AS non_festive_aov
    FROM category_period_summary
    GROUP BY category
)

SELECT
    category,
    festive_aov,
    non_festive_aov,
    ROUND(
        (festive_aov - non_festive_aov) * 100 / non_festive_aov,
        2
    ) AS aov_uplift_pct
FROM category_pivot
ORDER BY aov_uplift_pct DESC;