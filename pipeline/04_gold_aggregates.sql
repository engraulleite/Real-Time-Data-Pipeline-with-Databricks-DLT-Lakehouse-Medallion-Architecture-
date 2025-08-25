%sql
-- 04_gold_aggregates.sql
-- Example gold-level aggregated streaming table: daily sales by product + region
CREATE OR REFRESH STREAMING TABLE gold_db.str_gold_sales_daily
TBLPROPERTIES ("quality" = "gold")
AS
SELECT
  date_trunc('DD', __START_AT) AS sales_day,
  product_id,
  region,
  commodity,
  SUM(amount) AS total_amount,
  SUM(quantity) AS total_quantity,
  COUNT(DISTINCT order_id) AS distinct_orders
FROM STREAM(gold_db.str_gold_orders)   -- reads the effective rows (SCD type2 current view)
GROUP BY date_trunc('DD', __START_AT), product_id, region, commodity;
