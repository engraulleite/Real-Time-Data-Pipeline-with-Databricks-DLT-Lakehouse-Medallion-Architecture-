# Real-Time-Data-Pipeline-with-Databricks-DLT-Lakehouse-Medallion-Architecture-
The pipeline was designed as a **modern data engineering solution** using **Databricks Delta Live Tables (DLT / Lakeflow Declarative Pipelines)** to ingest, process, and serve **streaming data**.

## 📌 Project Overview
In a previous architecture, the data ingestion pipeline for the agribusiness e-commerce platform was built using a **batch full refresh strategy**. Every hour, the entire dataset was reprocessed from scratch, regardless of whether new data was present or not. This caused unnecessary compute usage, longer refresh times, and increased costs.  

To address this, the pipeline was re-engineered using **Lakeflow Declarative Pipelines/ Databricks Delta Live Tables (DLT)** with **Auto Loader** for streaming ingestion. Instead of reprocessing all data, Auto Loader continuously detects and ingests only **new or changed files** arriving in the AWS S3 bucket. This incremental approach drastically reduced compute time, lowered processing costs, and improved the overall freshness of data delivered to the business.  

- **Bronze Layer**: Raw ingestion of e-commerce order events directly from AWS S3 using Auto Loader.  
- **Silver Layer**: Data cleaning, type casting, deduplication, and application of **data quality constraints** (warn, drop, fail).  
- **Gold Layer**: Application of **CDC (Historical Tracking / SCD Type 2)** to maintain full history of order changes, and creation of aggregated sales tables for reporting.  
- **Continuous Pipeline**: Configured with **continuous trigger mode** so that new events arriving in the S3 bucket are processed automatically in near real-time.  

## ❓ The Problem
The main challenges faced with the old pipeline included:  
- **Full Refresh Processing**: The pipeline reloaded and transformed the entire dataset every hour.  
- **High Compute Costs**: Unnecessary reprocessing of unchanged data led to wasted cluster resources and elevated cloud costs.  
- **High Latency**: Data was only updated on an hourly basis, delaying insights and downstream analytics.  
- **Scalability Issues**: As data volumes grew, the pipeline became slower and increasingly expensive to maintain.  
- **Operational Inefficiency**: Failures during the refresh cycle required a complete rerun, delaying business users further.  

## 💡 The Architectural Solution
This project applies the **Lakehouse Medallion Architecture** to solve these challenges:

1. **Bronze (Raw Zone)**  
   - Ingests raw JSON events from AWS S3 using **Databricks Auto Loader (read_files)**.  
   - Adds ingestion metadata ( `_metadata.file_name`).  

2. **Silver (Cleaned Zone)**  
   - Cleanses and normalizes schema (cast types, deduplicate).  
   - Applies **DLT Expectations**:  
     - **Warn** → log invalid but non-critical records.  
     - **Drop** → remove rows violating mandatory constraints.  
     - **Fail** → stop pipeline on critical violations.  

3. **Gold (Business Zone)**  
   - Implements **CDC Historical Tracking (SCD Type 2)** using `AUTO CDC INTO`.  
   - Maintains full history of order changes (`__START_AT`, `__END_AT`).  
   - Builds **aggregated sales tables** (daily revenue, quantity, distinct orders).  

4. **Continuous Processing**  
   - Orchestrated via **Databricks Delta Live Tables (Lakeflow Declarative Pipelines)** in **continuous trigger mode**, ensuring streaming ingestion and transformation.  

## 🚀 Key Benefits Achieved
By adopting **Databricks Auto Loader** and redesigning the pipeline with **incremental streaming ingestion**, the following benefits were achieved:  

- **Cost Reduction (~70%)**: Processing only new data instead of full refresh significantly reduced compute usage.  
- **Faster Data Availability**: New events are ingested and processed in near real-time, reducing data delivery latency from **1 hour to a few seconds/minutes**.  
- **Scalability**: Auto Loader seamlessly handles large volumes and schema drift, ensuring the pipeline scales as data grows.  
- **Operational Resilience**: Failures now only affect incremental loads, not entire dataset refreshes, minimizing downtime.  
- **Improved Developer Productivity**: Simplified ingestion logic reduced pipeline complexity and maintenance overhead.  
- **Business Value**: Stakeholders now have fresher insights for decision-making, enabling faster reaction to changes in sales, demand, and logistics.
- **Data Quality Enforcement**: Automatic rules prevent bad data from polluting analytics.  
- **Historical Tracking**: Full audit trail of order lifecycle using CDC.  
- **Scalability**: Auto Loader handles schema drift and large event volumes efficiently.  
- **Lakehouse Unification**: Combines streaming ingestion with structured transformations in a single framework (DLT).  

## 🛠️ Technologies
- **Databricks** (Delta Live Tables / Lakeflow Declarative Pipelines)  
- **Delta Lake** (Bronze, Silver, Gold layered storage)  
- **AWS S3** (source bucket for raw JSON events)  
- **Auto Loader (read_files)** (incremental file ingestion)  
- **CDC (Change Data Capture)** with **SCD Type 2** tracking  
- **Databricks SQL / Spark Structured Streaming**  

## Architecture Diagram

![Diagrama da Arquitetura](docs/images/diagram_arq.png)
