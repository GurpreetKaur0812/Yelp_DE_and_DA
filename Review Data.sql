USE WAREHOUSE COMPUTE_WH;
USE DATABASE YELP;
USE SCHEMA PUBLIC;


create or replace table YELP (review_text variant);

COPY INTO YELP
FROM 's3://project-de-yelp-data/yelp/'
CREDENTIALS = (
AWS_KEY_ID = '**********'
AWS_SECRET_KEY = '*******************'
)
FILE_FORMAT = (TYPE = JSON);

SELECT * FROM YELP limit 100;

CREATE OR REPLACE TABLE tbl_yelp_reviews_v2 AS
SELECT
    review_text:review_id::string  AS review_id,
    review_text:user_id::string    AS user_id,
    review_text:business_id::string AS business_id,
    review_text:date::date         AS review_date,
    review_text:stars::number      AS review_stars,
    review_text:text::string       AS review_text,
    analyze_sentiment(review_text:text::string) AS sentiment
FROM YELP;

select * from tbl_yelp_reviews
limit 10
