# Olist E-Commerce Analysis

**Business Question:** What drives customer satisfaction and repeat purchases?

**Dataset:** [Brazilian E-Commerce Dataset (Olist)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — 100K+ orders, 2016–2018

**Dashboard:** [Tableau Public](https://public.tableau.com/app/profile/hanguel.lee/viz/OlistE-CommerceAnalysis_17813442268640/Dashboard1)

---

## Tools
- **Python (pandas)** — EDA & data cleaning
- **PostgreSQL** — star schema, analytical queries
- **Tableau Public** — interactive dashboard

---

## Project Structure
```
├── da_ecommerce_olist.ipynb   # EDA + data cleaning notebook
├── sql/
│   ├── schema.sql             # Star schema creation
│   ├── load_data.sql          # Load clean CSVs into PostgreSQL
│   ├── rfm_analysis.sql       # RFM customer segmentation
│   ├── cohort_analysis.sql    # Monthly cohort retention
│   └── delivery_impact.sql    # Delivery speed vs satisfaction
└── data/
    └── clean/                 # Cleaned CSVs (exported from notebook)
```

---

## Methodology

### 1. Data Cleaning (Python)
- Parsed all timestamp columns to datetime
- Filtered to delivered orders only (96,456 of 99,441)
- Translated product category names from Portuguese to English
- Imputed missing product dimensions with category median
- Deduplicated geolocation table (981K → 19K unique zip codes)
- Built master analytical table joining orders, customers, reviews, payments

### 2. Database (PostgreSQL — Star Schema)
```
fact_orders ──── dim_customers
            ──── dim_products (via bridge_order_items)
            ──── dim_sellers  (via bridge_order_items)
```

### 3. RFM Segmentation (SQL)
Scored each customer 1–5 on Recency, Frequency, and Monetary value using `NTILE(5)`. Assigned segments based on score combinations.

### 4. Cohort Analysis (SQL)
Grouped customers by month of first purchase. Tracked what % returned in each subsequent month.

### 5. Dashboard (Tableau)
5 charts arranged to tell a connected story — from revenue growth context to the root cause of low retention.

---

## Key Insights

**1. Delivery speed is the strongest driver of satisfaction**
| Delivery Time | Satisfaction Rate |
|---|---|
| Under 5 days | 86.5% |
| 6–10 days | 84.4% |
| 11–20 days | 80.0% |
| Over 20 days | **49.8%** |

Satisfaction drops by 37 percentage points when delivery exceeds 20 days.

**2. Retention is near zero across all cohorts**
Less than 1% of customers return after their first purchase, regardless of which month they joined. This is consistent across all 20 cohorts analysed (Jan 2017 – Aug 2018).

**3. At Risk segment represents the biggest revenue opportunity**
21,917 customers who previously spent well (avg R$242) have not returned in an average of 426 days — representing R$5.3M in potentially recoverable revenue.

---

## Recommendations

1. **Invest in logistics** to reduce deliveries exceeding 20 days — this alone could recover 37% satisfaction gap
2. **Win-back campaign** targeting the At Risk segment (21K customers, R$5.3M revenue)
3. **First-purchase experience** — since nearly all customers only buy once, the first order is the only chance to convert them into repeat buyers
