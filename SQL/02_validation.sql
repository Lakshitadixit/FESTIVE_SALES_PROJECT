-- ========================================
-- 02_validation.sql
-- Purpose: Validate loaded sales_fact data
-- ========================================

-- 1. Row count check
SELECT COUNT(*) AS total_rows
FROM sales_fact;


-- 2. Primary key safety (should be zero)
SELECT COUNT(*) AS duplicate_order_ids
FROM (
    SELECT order_id
    FROM sales_fact
    GROUP BY order_id
    HAVING COUNT(*) > 1
) d;


-- 3. Null checks for critical columns
SELECT
    COUNT(*) FILTER (WHERE order_id IS NULL)      AS null_order_id,
    COUNT(*) FILTER (WHERE order_date IS NULL)    AS null_order_date,
    COUNT(*) FILTER (WHERE final_amount IS NULL)  AS null_final_amount
FROM sales_fact;


-- 4. Invalid numeric values (should be zero)
SELECT COUNT(*) AS invalid_quantity_or_price
FROM sales_fact
WHERE quantity <= 0
   OR unit_price <= 0;


-- 5. Discount sanity check
SELECT COUNT(*) AS invalid_discount_values
FROM sales_fact
WHERE discount_pct < 0
   OR discount_pct > 100;


-- 6. Final amount logic validation
-- final_amount = quantity * unit_price * (1 - discount_pct/100)
SELECT COUNT(*) AS invalid_final_amount
FROM sales_fact
WHERE ROUND(
        quantity * unit_price * (1 - discount_pct / 100.0),
        2
      ) <> final_amount;


-- 7. Date range validation (project scope = 2024)
SELECT
    MIN(order_date) AS min_order_date,
    MAX(order_date) AS max_order_date
FROM sales_fact;