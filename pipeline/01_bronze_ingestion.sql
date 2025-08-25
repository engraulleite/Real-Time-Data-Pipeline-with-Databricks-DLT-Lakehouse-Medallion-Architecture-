%sql
-- dlt_pipeline/01_bronze_ingestion.sql
-- Ingesting raw data from S3 to the Bronze tier

CREATE OR REFRESH STREAMING TABLE bronze_db.str_bronze_orders
    COMMENT "Ingest order JSON files from cloud storage"
    TBLPROPERTIES (
    "quality" = "bronze",
    "pipelines.reset.allowed" = false 
    )
AS
SELECT
    *,
    current_timestamp() AS processing_time,
    _metadata.file_name AS source_file
FROM STREAM read_files(
    "s3://bucket_path/landing-zone/orders/",
    format => 'JSON'
);
