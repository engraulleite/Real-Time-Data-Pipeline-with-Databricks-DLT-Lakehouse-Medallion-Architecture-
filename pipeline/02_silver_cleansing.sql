%sql
--dlt_pipeline/02_silver_cleansing.sql
-- Silver: cleaned, typed and quality-checked data.

CREATE OR REFRESH STREAMING TABLE silver_db.str_silver_orders (
  CONSTRAINT order_id_not_null EXPECT (order_id IS NOT NULL) ON VIOLATION DROP ROW, -- If null order_id -> DROP the row (business key mandatory)
  CONSTRAINT positive_amount EXPECT (amount IS NULL OR amount >= 0) ON VIOLATION FAIL UPDATE, -- Negative amounts are unacceptable -> FAIL the update
  CONSTRAINT valid_status EXPECT (status IN ('NEW','PROCESSING','SHIPPED','CANCELLED')) -- Status outside allowed list: WARN (default behavior keeps row but logs metrics)
) TBLPROPERTIES ("quality" = "silver")
AS
SELECT
  order_id,
  CAST(event_time AS TIMESTAMP) AS event_time,
  customer_id,
  farm_id,
  region,
  product_id,
  commodity,
  CAST(quantity AS INT) AS quantity,
  CAST(amount AS DOUBLE) AS amount,
  status,
  operation,        
  sequenceNum,      
  ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY event_time DESC, sequenceNum DESC) as order_latest,
  processing_time,
  source_file
FROM STREAM(bronze_db.str_bronze_orders)
QUALIFY order_latest = 1; -- Deduplicate, keeping latest by event_time (qualify supported in Databricks SQL)
