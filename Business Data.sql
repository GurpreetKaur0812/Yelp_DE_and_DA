USE WAREHOUSE COMPUTE_WH;
USE DATABASE YELP;
USE SCHEMA PUBLIC;

create or replace table YELP_business (business_text variant);

COPY INTO YELP_BUSINESS
FROM 's3://project-de-yelp-data/yelp business/'
CREDENTIALS = (
AWS_KEY_ID = '**********'
AWS_SECRET_KEY = '********************'
)
FILE_FORMAT = (TYPE = JSON);

SELECT * FROM yelp_business limit 100;

create table tbl_yelp_business as 
select business_text:business_id::string as business_id
,business_text:city::string as city
,business_text:state::string as state
,business_text:review_count::string as review_count
,business_text:stars::string as stars
,business_text:categories::string as categories
from yelp_business;

SELECT * FROM tbl_yelp_business limit 100;
