#ROLLUP: сколько каждый из сотрудников заработал для фирмы денег по датам и за все время 
with staff_rental as ( 
	select
		s.last_name staff_name,
		p.amount,
		DATE_FORMAT(p.payment_date, '%Y-%m') date1
	from sakila.staff s
	inner join sakila.rental r
		on r.staff_id = s.staff_id
	inner join sakila.payment p
		on p.rental_id = r.rental_id
) 
select 
	CASE GROUPING(staff_name)
		when 1 then 'All employees'
		else staff_name
	end as staff_name,
	CASE GROUPING(date1)
		when 1 then 'All dates'
		else date1
	end as date1,
	sum(amount) as amount
from staff_rental
group by staff_name, date1
with ROLLUP
;


#ROLLUP: сколько каждый из сотрудников заработал денег по клиентам 
with staff_customers as ( 
	select
		s.last_name staff_name,
		p.amount,
		c.last_name customer
	from sakila.staff s
	inner join sakila.rental r
		on r.staff_id = s.staff_id
	inner join sakila.payment p
		on p.rental_id = r.rental_id
	inner join sakila.customer c
		on r.customer_id = c.customer_id
) 
select 
	CASE GROUPING(staff_name)
		when 1 then 'All employees'
		else staff_name
	end as staff_name,
	CASE GROUPING(customer)
		when 1 then 'All customers'
		else customer
	end as customer,
	sum(amount) as amount
from staff_customers
GROUP BY staff_name, customer
with ROLLUP
;


#ROLLUP: сколько каждый из клиентов принес денег фирме - по клиентам и месяцам
with rental_data as ( 
	select
		p.amount,
		c.last_name customer,
		DATE_FORMAT(p.payment_date, '%Y-%m') date1
	from sakila.rental r
	inner join sakila.payment p
		on p.rental_id = r.rental_id
	inner join sakila.customer c
		on r.customer_id = c.customer_id
) 
select 
	CASE GROUPING(customer)
		when 1 then 'All customers'
		else customer
	end as customer,
	CASE GROUPING(date1)
		when 1 then 'All dates'
		else date1
	end as date1,
	sum(amount) as amount
from rental_data
GROUP BY customer, date1
WITH ROLLUP
;


#ROLLUP: какие категории фильмов принесли прокату сколько дохода - в т.ч. помесячно
with rental_data as ( 
	select
		p.amount,
		DATE_FORMAT(p.payment_date, '%Y-%m') date1,
		f.rating
	from sakila.rental r
	inner join sakila.payment p
		on p.rental_id = r.rental_id
	inner join sakila.inventory i
		on i.inventory_id = r.inventory_id
	inner join sakila.film f
		on f.film_id = i.film_id
) 
select 
	CASE GROUPING(rating)
		when 1 then 'All ratings'
		else rating
	end as rating,
	CASE GROUPING(date1)
		when 1 then 'All dates'
		else date1
	end as date1,
	sum(amount) as amount
from rental_data
GROUP BY rating, date1
WITH ROLLUP
;
