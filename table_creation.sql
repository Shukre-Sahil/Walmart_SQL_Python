drop table if exists walmart;
create table walmart(
invoice_id	int,
Branch	varchar(10),
City	varchar(25),
category	varchar(25),
unit_price	float,
quantity	int,
date	date,
time	time,
payment_method varchar(15),
rating	float,
profit_margin float,	
Total float

);

select * from walmart;

