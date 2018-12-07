select district, count(customer.customer_id) as customers_count
from address
	join customer 
		on customer.address_id = address.address_id
group by district
order by customers_count desc;

select row_number() over (order by last_name),*
from public.customer 
	 join public.address 
	 	on address.address_id = customer.address_id
where address.district = 'Buenos Aires'
order by last_name;

select rank() over (order by store_id),*
from public.customer 
	 join public.address 
	 	on address.address_id = customer.address_id
where address.district in ('Buenos Aires', 'Shandong', 'West Bengali')
order by last_name;

select dense_rank() over (order by store_id),*
from public.customer 
	 join public.address 
	 	on address.address_id = customer.address_id
where address.district in ('Buenos Aires', 'Shandong', 'West Bengali')
order by last_name;

select lag(amount) over (order by payment_date) as lag, 
lag(amount,2) over (order by payment_date) as lag_offset2, 
lead(amount) over (order by payment_date) as lead,
*
from payment
where customer_id = 560;

select lag(amount) over w as lag, 
lag(amount,2) over w as lag_offset2, 
lead(amount) over w as lead,
FIRST_VALUE(amount) over (partition by staff_id order by payment_date) as fsrt,
LAST_VALUE(amount) over (partition by staff_id order by payment_date) as lst,
amount,
*
from payment
where customer_id = 560
window w as (order by payment_date)
order by payment_date,staff_id;

select lag(amount) over w as lag, 
lag(amount,2) over w as lag_offset2, 
lead(amount) over w as lead,
FIRST_VALUE(amount) over (partition by staff_id order by payment_date) as fsrt,
LAST_VALUE(amount) over (partition by staff_id order by payment_date) as lst,
NTH_VALUE(amount,5) over (partition by staff_id order by payment_date) as "5th",
amount,
*
from payment
where customer_id = 560
window w as (order by payment_date)
order by staff_id,payment_date;

select amount, (select SUM(amount)
				from payment as ip
				where ip.payment_date <= op.payment_date 
					and ip.customer_id = op.customer_id) as total, *
from payment as op
where customer_id = 560;

select amount, SUM(amount) over (order by payment_date) as total,*
from payment
where customer_id = 560;

select amount, 
SUM(amount) over (partition by customer_id) as total,
SUM(amount) over (partition by customer_id order by payment_date) as total,*
from payment;

select amount, 
ntile(10) over (order by payment_id) as groupid,*
from payment
where customer_id = 560;

select amount, 
CUME_DIST() over (order by payment_id) as distrib,
PERCENT_RANK() over (order by payment_id) as distrib,
*
from payment
where customer_id = 560;

select amount, (select SUM(amount)
				from payment as ip
				where ip.payment_date <= op.payment_date 
					and ip.customer_id = op.customer_id
					and ip.staff_id = op.staff_id) as total, *
from payment as op
where customer_id = 560
order by payment_date;

select amount, SUM(amount) over (partition by staff_id order by payment_date) as total,*
from payment
where customer_id = 560;

select sum(id) over (order by shipname),*
from public.pirates
order by shipname;ер группы, и

 select customer.customer_id, customer.last_name, customer.first_name, payment.payment_date, payment.amount,
		rank() over (partition by payment.customer_id order by payment.amount DESC) as rnk
	from payment
		join customer
			on customer.customer_id = payment.customer_id;

select *
from 
	(select customer.customer_id, customer.last_name, customer.first_name, payment.payment_date, payment.amount,
		rank() over (partition by payment.customer_id order by payment.amount DESC) as rnk
	from payment
		join customer
			on customer.customer_id = payment.customer_id) as top_clients
where rnk <= 2;

select *
from 
	(select customer.customer_id, customer.last_name, customer.first_name, payment.payment_date, payment.amount,
		row_number() over (partition by payment.customer_id order by payment.amount desc,payment_date desc) as rnk
	from payment
		join customer
			on customer.customer_id = payment.customer_id) as top_clients
where rnk <= 2;
