-- 01_schema.sql
-- Defines core tables for Festive Sales Analysis

DROP TABLE IF EXISTS sales_fact;

CREATE TABLE sales_fact (
    order_id        VARCHAR(30) PRIMARY KEY,
    order_date      DATE NOT NULL,
    cust_id         VARCHAR(50),
    gender          VARCHAR(20),
    state           VARCHAR(50),
    region          VARCHAR(50),
    category        VARCHAR(50),
    sub_category    VARCHAR(100),
    product_name    VARCHAR(100),
    quantity        INT CHECK (quantity > 0),
    unit_price      INT CHECK (unit_price > 0),
    discount_pct    NUMERIC(5,2) CHECK (discount_pct >= 0 AND discount_pct <= 100),
    final_amount    NUMERIC(12,2) CHECK (final_amount >= 0),
    payment_mode    VARCHAR(30)
);