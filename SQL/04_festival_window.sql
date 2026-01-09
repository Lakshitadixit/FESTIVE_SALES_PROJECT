-- =========================================================
-- 04_festival_window.sql
-- Purpose: Assign each order to its nearest festival
--          within a 15-day pre-festival window
-- =========================================================

CREATE OR REPLACE VIEW festival_window AS
WITH festival_matches AS (
    SELECT
        s.order_id,
        s.order_date,
        s.final_amount,
        f.festival_name,
        f.festival_date,
        (f.festival_date - s.order_date) AS days_to_festival,
        ROW_NUMBER() OVER (
            PARTITION BY s.order_id
            ORDER BY (f.festival_date - s.order_date)
        ) AS rn
    FROM sales_fact s
    JOIN festival_calendar f
      ON s.order_date BETWEEN
         f.festival_date - INTERVAL '15 days'
     AND f.festival_date
)

SELECT
    order_id,
    order_date,
    final_amount,
    festival_name,
    festival_date,
    days_to_festival
FROM festival_matches
WHERE rn = 1;
