%sql
-- 03_cdc_gold.sql
-- Create the target streaming table that will store SCD Type 2 records
CREATE OR REFRESH STREAMING TABLE gold_db.str_gold_orders;

-- Create a flow that applies CDC from silver_orders_clean into gold_orders
CREATE FLOW gold_orders_cdc AS
AUTO CDC INTO str_gold_orders
FROM STREAM(silver_db.str_silver_orders)
KEYS (order_id)
APPLY AS DELETE WHEN status = 'CANCELLED'          -- example: cancelled => delete
SEQUENCE BY COALESCE(sequenceNum, unix_timestamp(event_time) * 1000)
COLUMNS * EXCEPT (operation, sequenceNum)
STORED AS SCD TYPE 2
TRACK HISTORY ON *;
