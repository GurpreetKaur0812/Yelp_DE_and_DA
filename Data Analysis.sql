USE DATABASE YELP;
USE SCHEMA PUBLIC;

-- No of business in each category

with cte as (
select business_id, trim(A.value) as category
from tbl_yelp_business
, lateral split_to_table(categories, ',') A
)
select category, count(*) as no_of_business
from cte
group by 1
order by 2 desc;

-- top 10 users that reviwed the most businesses in "Restarant" category

select r.user_id, count(distinct r.business_id)
from tbl_yelp_reviews r
inner join tbl_yelp_business b 
on r.business_id=b.business_id
where b.categories ilike '%restaurant%'
group by 1
order by 2 desc
limit 10;

-- Most populer categories of businesses based on the number of review
with cte as (
select business_id, trim(A.value) as category
from tbl_yelp_business
, lateral split_to_table(categories, ',') A
)
select category, count(*) as no_of_reviews
from cte
inner join tbl_yelp_reviews r on cte.business_id = r.business_id
group by 1
order by 2 desc

-- Top 8 most recent reviews for each business
with cte as (
select r.*
, row_number() over(partition by r.business_id order by review_date desc) as rn
from tbl_yelp_reviews r
inner join tbl_yelp_business b 
on r.business_id = b.business_id
)
select * from cte
where rn<=8;

-- Month with the highest number of reviews
Select Month(review_date) as review_month, count(*) as no_of_reviews
from tbl_yelp_reviews
group by 1
order by 2 desc
limit 1;
