-- ============================================================
-- Olist E-Commerce Star Schema
-- ============================================================

DROP TABLE IF EXISTS fact_orders CASCADE;
DROP TABLE IF EXISTS dim_customers CASCADE;
DROP TABLE IF EXISTS dim_products CASCADE;
DROP TABLE IF EXISTS dim_sellers CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;

-- Dimension: Customers
CREATE TABLE dim_customers (
    customer_id             TEXT PRIMARY KEY,
    customer_unique_id      TEXT,
    customer_zip_code       TEXT,
    customer_city           TEXT,
    customer_state          TEXT
);

-- Dimension: Products
CREATE TABLE dim_products (
    product_id                  TEXT PRIMARY KEY,
    product_category_name       TEXT,
    category_en                 TEXT,
    product_weight_g            NUMERIC,
    product_length_cm           NUMERIC,
    product_height_cm           NUMERIC,
    product_width_cm            NUMERIC
);

-- Dimension: Sellers
CREATE TABLE dim_sellers (
    seller_id               TEXT PRIMARY KEY,
    seller_zip_code         TEXT,
    seller_city             TEXT,
    seller_state            TEXT
);

-- Dimension: Date
CREATE TABLE dim_date (
    date_id     DATE PRIMARY KEY,
    year        INT,
    month       INT,
    quarter     INT,
    day_of_week INT,
    month_name  TEXT
);

-- Fact: Orders
CREATE TABLE fact_orders (
    order_id                        TEXT PRIMARY KEY,
    customer_id                     TEXT REFERENCES dim_customers(customer_id),
    order_status                    TEXT,
    order_purchase_timestamp        TIMESTAMP,
    order_delivered_customer_date   TIMESTAMP,
    order_estimated_delivery_date   TIMESTAMP,
    delivery_days                   INT,
    delay_days                      INT,
    purchase_year                   INT,
    purchase_month                  INT,
    purchase_quarter                INT,
    review_score                    NUMERIC,
    satisfied                       INT,
    total_payment                   NUMERIC,
    payment_installments            INT,
    item_count                      INT,
    total_freight                   NUMERIC
);

-- Order items bridge (links orders to products/sellers)
DROP TABLE IF EXISTS bridge_order_items CASCADE;
CREATE TABLE bridge_order_items (
    order_id        TEXT REFERENCES fact_orders(order_id),
    product_id      TEXT REFERENCES dim_products(product_id),
    seller_id       TEXT REFERENCES dim_sellers(seller_id),
    order_item_id   INT,
    price           NUMERIC,
    freight_value   NUMERIC,
    PRIMARY KEY (order_id, order_item_id)
);
