-- ============================================================
-- Load clean CSVs into PostgreSQL
-- Run from psql: \i /Users/hanguellee/da_project/da_ecommerce/sql/load_data.sql
-- ============================================================

-- Customers
COPY dim_customers(customer_id, customer_unique_id, customer_zip_code, customer_city, customer_state)
FROM '/Users/hanguellee/da_project/da_ecommerce/da_ecommerce/data/clean/customers_clean.csv'
CSV HEADER;

-- Products (CSV has extra columns — use a staging approach)
CREATE TEMP TABLE stg_products (
    product_id                  TEXT,
    product_category_name       TEXT,
    product_name_lenght         TEXT,
    product_description_lenght  TEXT,
    product_photos_qty          TEXT,
    product_weight_g            NUMERIC,
    product_length_cm           NUMERIC,
    product_height_cm           NUMERIC,
    product_width_cm            NUMERIC,
    product_category_name_english TEXT,
    category_en                 TEXT
);
COPY stg_products FROM '/Users/hanguellee/da_project/da_ecommerce/da_ecommerce/data/clean/products_clean.csv' CSV HEADER;
INSERT INTO dim_products(product_id, product_category_name, product_weight_g, product_length_cm, product_height_cm, product_width_cm, category_en)
SELECT product_id, product_category_name, product_weight_g, product_length_cm, product_height_cm, product_width_cm, category_en
FROM stg_products;
DROP TABLE stg_products;

-- Sellers
COPY dim_sellers(seller_id, seller_zip_code, seller_city, seller_state)
FROM '/Users/hanguellee/da_project/da_ecommerce/da_ecommerce/data/clean/sellers_clean.csv'
CSV HEADER;

-- Fact orders (master has extra columns — stage and select)
CREATE TEMP TABLE stg_master (
    order_id                        TEXT,
    customer_id                     TEXT,
    order_status                    TEXT,
    order_purchase_timestamp        TEXT,
    order_approved_at               TEXT,
    order_delivered_carrier_date    TEXT,
    order_delivered_customer_date   TEXT,
    order_estimated_delivery_date   TEXT,
    delivery_days                   NUMERIC,
    delay_days                      NUMERIC,
    purchase_year                   INT,
    purchase_month                  INT,
    purchase_quarter                INT,
    customer_unique_id              TEXT,
    customer_zip_code_prefix        TEXT,
    customer_city                   TEXT,
    customer_state                  TEXT,
    review_score                    NUMERIC,
    satisfied                       NUMERIC,
    total_payment                   NUMERIC,
    payment_installments            NUMERIC,
    item_count                      NUMERIC,
    total_freight                   NUMERIC
);
COPY stg_master FROM '/Users/hanguellee/da_project/da_ecommerce/da_ecommerce/data/clean/master.csv' CSV HEADER;
INSERT INTO fact_orders(order_id, customer_id, order_status, order_purchase_timestamp,
                        order_delivered_customer_date, order_estimated_delivery_date,
                        delivery_days, delay_days, purchase_year, purchase_month, purchase_quarter,
                        review_score, satisfied, total_payment, payment_installments,
                        item_count, total_freight)
SELECT order_id, customer_id, order_status,
       order_purchase_timestamp::TIMESTAMP,
       order_delivered_customer_date::TIMESTAMP,
       order_estimated_delivery_date::TIMESTAMP,
       delivery_days::INT, delay_days::INT,
       purchase_year, purchase_month, purchase_quarter,
       review_score, satisfied::INT, total_payment, payment_installments::INT,
       item_count::INT, total_freight
FROM stg_master;
DROP TABLE stg_master;

-- Order items bridge
CREATE TEMP TABLE stg_items (
    order_id            TEXT,
    order_item_id       INT,
    product_id          TEXT,
    seller_id           TEXT,
    shipping_limit_date TEXT,
    price               NUMERIC,
    freight_value       NUMERIC
);
COPY stg_items FROM '/Users/hanguellee/da_project/da_ecommerce/da_ecommerce/data/clean/order_items_clean.csv' CSV HEADER;
INSERT INTO bridge_order_items(order_id, order_item_id, product_id, seller_id, price, freight_value)
SELECT order_id, order_item_id, product_id, seller_id, price, freight_value
FROM stg_items
WHERE order_id IN (SELECT order_id FROM fact_orders);
DROP TABLE stg_items;

-- Verify row counts
SELECT 'dim_customers'    AS table_name, COUNT(*) AS rows FROM dim_customers    UNION ALL
SELECT 'dim_products',                   COUNT(*)         FROM dim_products      UNION ALL
SELECT 'dim_sellers',                    COUNT(*)         FROM dim_sellers       UNION ALL
SELECT 'fact_orders',                    COUNT(*)         FROM fact_orders       UNION ALL
SELECT 'bridge_order_items',             COUNT(*)         FROM bridge_order_items
ORDER BY table_name;
