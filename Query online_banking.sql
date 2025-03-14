
create database online_banking;

create table region (
  region_id INTEGER,
  region_name VARCHAR(9)
);

INSERT INTO region
  (region_id, region_name)
VALUES
  ('1', 'Dhaka'),
  ('2', 'Khulna'),
  ('3', 'Rajshahi'),
  ('4', 'Sylhet'),
  ('5', 'Barishal');

create table area
(
    area_id int,
    name varchar(20)
);
insert into area values (1,'Union'),(2,'Upazila'),(3,'Pouroshova'),(4,'Ward'),(5,'Village');


-- You will get the data from excel (No need to execute the below DDL)
CREATE TABLE customer_joining_info(
  customer_id INTEGER,
  region_id INTEGER,
  area_id INTEGER,
  join_date DATE
);


-- You will get the data from excel (No need to execute the below DDL)
CREATE TABLE customer_transactions (
  customer_id INTEGER,
  txn_date DATE,
  txn_type VARCHAR(10),
  txn_amount INTEGER
);


