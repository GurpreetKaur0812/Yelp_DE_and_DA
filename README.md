# Yelp Data Analytics Project (End-to-End)

## Overview
This project is an end-to-end **Data Analytics and Data Engineering pipeline** built using **Python, AWS S3, Snowflake, and SQL**.  
The objective of this project is to ingest large-scale JSON data, transform it into analytical tables, enrich it with sentiment analysis, and answer meaningful business questions using SQL.

Due to the size of the dataset, the raw data is **not included in this repository**. This README serves both as **project documentation** and a **step-by-step guide** to reproduce the workflow.

---

## Dataset
**Source:** Yelp Open Dataset  
**Link:** https://business.yelp.com/data/resources/open-dataset/

The dataset consists of multiple large JSON files containing:
- Business data
- Review data
- User data (embedded within reviews)

---

## Architecture & Workflow

### 1. Data Extraction
- Downloaded the Yelp Open Dataset (compressed JSON files).
- Extracted the files locally.
- Identified the **review dataset (~5 GB)** as the largest bottleneck.

---

### 2. Data Preprocessing (Python)
- Split the large review JSON file into **10 smaller JSON files (~500 MB each)** using Python.
- This step was performed to:
  - Improve ingestion speed
  - Avoid memory and timeout issues
  - Enable smoother loading into Snowflake

> **Note:** The number of splits can be adjusted (10, 15, 20, etc.) based on system capacity.

---

### 3. Cloud Storage (AWS S3)
- Created an **AWS S3 bucket** to store the processed JSON files.
- Configured **IAM**:
  - Created an IAM user
  - Assigned S3 access permissions
  - Generated access keys
- Uploaded:
  - Split review JSON files
  - Business JSON file

---

### 4. Snowflake Setup
- Created the following in Snowflake:
  - **Warehouse**
  - **Database (`YELP`)**
  - **Schema (`PUBLIC`)**
- Connected Snowflake to AWS S3.
- Loaded JSON data using `COPY INTO`.

> Snowflake automatically treats **multiple JSON files as a single logical dataset**.

---

## Data Modeling

### Base Tables
- **YELP_REVIEWS_RAW**
  - Column: `review_text` (VARIANT)
- **YELP_BUSINESS_RAW**
  - Column: `business_data` (VARIANT)

---

### Analytical Tables

#### Reviews Table
Extracted structured columns from JSON:
- `review_id`
- `user_id`
- `business_id`
- `review_date`
- `review_stars`
- `review_text`
- `sentiment`

Sentiment analysis was applied using a **Python UDF** in Snowflake.

---

#### Business Table
Extracted:
- `business_id`
- `city`
- `state`
- `review_count`
- `stars`
- `categories`

---

## Sentiment Analysis
- Implemented using a **Python UDF** in Snowflake.
- Classified reviews into:
  - **Positive**
  - **Neutral**
  - **Negative**
- Required a **larger warehouse** due to compute-intensive execution.

---

## Analytical Queries

The following analyses were performed using SQL:

1. **Number of businesses in each category**
2. **Top 10 users who reviewed the most businesses in the restaurant category**
3. **Most popular business categories based on review count**
4. **Top 8 most recent reviews for each business**
5. **Month with the highest number of reviews**

Advanced SQL concepts used:
- Window functions
- Lateral flattening
- Aggregations
- Ranking functions

---

## Errors Faced & How They Were Resolved

### Missing `user_id` in Reviews Table
- **Issue:** `user_id` was missed during initial table creation.
- **Cause:** JSON was cast to STRING too early, resulting in loss of metadata.
- **Fix:**
  - Joined back to the raw VARIANT table.
  - Used a larger warehouse to safely execute updates.

---

### JSON Extraction Errors
- **Issue:** JSON path extraction failed on STRING columns.
- **Fix:** Ensured all JSON operations were performed only on VARIANT columns.

---

### Warehouse & Context Errors
- **Issue:** Tables were not accessible across different worksheets.
- **Fix:** Explicitly set:
  - `USE DATABASE`
  - `USE SCHEMA`
  - `USE WAREHOUSE`
  in every session.

---

### Python Runtime Errors
- **Issue:** Python 3.8 runtime was deprecated in Snowflake.
- **Fix:** Updated Python UDF runtime to **Python 3.10**.

---

## Key Learnings
- Never discard **VARIANT** data before completing transformations.
- Always retain a **stable identifier** (e.g., `review_id`) early in the pipeline.
- Snowflake automatically combines multiple files into one dataset.
- Warehouse sizing significantly impacts Python UDF performance.
- Snowflake context (database/schema) is **session-specific**.

---

## Tech Stack
- **Python**
- **AWS S3 & IAM**
- **Snowflake**
- **SQL**
- **Snowflake Python UDFs**

---

## Notes
- Raw data is excluded due to size constraints.
- This repository focuses on **architecture, transformations, SQL logic, and analytical outcomes**.
