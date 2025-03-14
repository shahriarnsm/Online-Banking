
-- 1. How many unique customers are there?
select count(distinct customer_id)
from customer_joining_info;


-- 2. How many unique customers are coming from each region?
select
       r.region_id,
       region_name,
       total_customer
from
(select region_id,
       count(distinct customer_id) as total_customer
from customer_joining_info
group by region_id) as t
inner join region as r on t.region_id = r.region_id;


-- 3. How many unique customers are coming from each area?
select t.area_id as area_id,
       a.name,
       total_customer
from
(select area_id,
    count(distinct customer_id) as total_customer
from customer_joining_info
group by area_id)as t
inner join area as a on t.area_id = a.area_id;


-- 4. What is the total amount for each transaction type? **
select txn_type,
    sum(txn_amount)as tota_ammount
from customer_transactions
group by txn_type;


-- 5. For each month - how many customers make more than 1 deposit and 1 withdrawal in a single month?
select  months, count(distinct customer_id)as total_customer
from (select month(txn_date)as months, customer_id,
             count(CASE WHEN txn_type = 'deposit' THEN 1 END) AS deposit,
             count(CASE WHEN txn_type = 'withdrawal' THEN 1 END) AS withdrawal
      from customer_transactions
      where txn_type in ('deposit', 'withdrawal')
      group by month(txn_date), customer_id
      HAVING deposit > 1 AND withdrawal > 1)as t
group by months;


-- 6. What is closing balance for each customer?
select distinct customer_id,
       sum(case when txn_type = 'deposit' then txn_amount else 0 end)-
       sum(case when txn_type = 'withdrawal' then txn_amount else 0 end) as closing_balance
from customer_transactions
group by customer_id
order by customer_id asc;


-- 7. What is the closing balance for each customer at the end of the month?
select distinct customer_id,
                month(txn_date)as tx_month,
       sum(case when txn_type = 'deposit' then txn_amount else 0 end)-
       sum(case when txn_type = 'withdrawal' then txn_amount else 0 end) as closing_balance
from customer_transactions
group by customer_id, month(txn_date)
order by customer_id asc;


-- 8. Please show the latest 5 days total withdraw amount.
select sum(txn_amount) as latest_5_days_total_withdraw
from

(select *,
       row_number() over (order by txn_date desc ) as row_count
       -- dense_rank() over (order by txn_date desc ) as rnk
      from customer_transactions
      where txn_type = 'withdrawal')as t
where row_count between 1 and 5;




select
       customer_id,
       sum(txn_amount) as withdrawal_amount
from (select *,
             dense_rank() over (partition by customer_id order by txn_date desc ) as rnk
      from customer_transactions
      where txn_type = 'withdrawal'
      order by customer_id, txn_date)as t
where rnk between 1 and 5
group by customer_id;


-- 9. Find out the total deposit amount for every five days consecutive series. You can assume 1 week = 5 days.
--   Please show the result week wise total amount.
select customer_id, year(txn_date)as 'Year',
       month(txn_date)as 'Month',
       weeks,
       sum(txn_amount) as total_deposit
from (select *,
             dense_rank() over (partition by month(txn_date) order by day(txn_date) asc )              as days,
             ceiling(dense_rank() over (partition by month(txn_date) order by day(txn_date) asc ) / 5) as weeks
      from customer_transactions
      where txn_type = 'deposit'
      order by customer_id, txn_date) as t
group by customer_id, year(txn_date), month(txn_date), weeks
order by customer_id, Month, weeks;


select customer_id, year(txn_date)as 'Year',
       month(txn_date)as 'Month',
       weeks,
       sum(txn_amount) as total_withdrawal
from (select *,
             dense_rank() over (partition by month(txn_date) order by day(txn_date) asc )              as days,
             ceiling(dense_rank() over (partition by month(txn_date) order by day(txn_date) asc ) / 5) as weeks
      from customer_transactions
      where txn_type = 'withdrawal'
      order by customer_id, txn_date) as t
group by customer_id, year(txn_date), month(txn_date), weeks
order by customer_id, Month, weeks;


-- 10. Please compare every weeks total deposit amount by the following previous week.
--	Example: Week 1 will be compared with Week 2 [Calculation Week2 - Week 1]-> Next week - previous week
--	Week 2 will be compared with Week 3  [Calculation Week3 - Week 2]
select
      Month,weeks, total_deposit,
      lag(total_deposit) over (partition by Month) as next_week_deposit,
      (total_deposit - lag(total_deposit) over (partition by Month)) as comp,
      row_number() over (order by Month) as total_weeks
from (select year(txn_date)  as 'Year',
             month(txn_date) as 'Month',
             weeks,
             sum(txn_amount) as total_deposit
      from (select *,
                   dense_rank() over (partition by month(txn_date) order by day(txn_date) asc )              as days,
                   ceiling(dense_rank() over (partition by month(txn_date) order by day(txn_date) asc ) / 5) as weeks
            from customer_transactions
            where txn_type = 'deposit'
            order by customer_id, txn_date) as t
      group by year(txn_date), month(txn_date), weeks
      order by Month, weeks) as t2;


-- --------------------------------------------------------------------------------------------
