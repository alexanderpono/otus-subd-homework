#запрос 2 - версия без аналитической функции 
#По каждому работнику проката выведете последнего клиента, которому сотрудник сдал что-то в прокат
#В результатах должны быть ид и фамилия сотрудника, ид и фамилия клиента, дата аренды
explain
select 
	staff_id,
	staff_last_name,
	last_rent_time,
	r6_customer_id,
	c.last_name customer_last_name
from (
	select 
		s.staff_id as staff_id, 
		s.last_name staff_last_name,
		(
			select distinct r4.rental_date 
			from sakila.rental r4 
			where r4.staff_id=s.staff_id
			order by rental_date desc
			limit 1
		) as last_rent_time,
		(
			select r6.customer_id 
			from sakila.rental r6 
			where r6.staff_id=s.staff_id and r6.rental_date = last_rent_time
			order by rental_date desc, r6.customer_id
			limit 1
		) as r6_customer_id
	from sakila.staff s
	order by s.staff_id
) as results
inner join sakila.customer c 
	on c.customer_id = r6_customer_id
;



explain
with results as (
	select 
		s.staff_id as staff_id, 
		s.last_name staff_last_name,
		(
			select distinct r4.rental_date 
			from sakila.rental r4 
			where r4.staff_id=s.staff_id
			order by rental_date desc
			limit 1
		) as last_rent_time,
		(
			select r6.customer_id 
			from sakila.rental r6 
			where r6.staff_id=s.staff_id and r6.rental_date = last_rent_time
			order by rental_date desc, r6.customer_id
			limit 1
		) as r6_customer_id
	from sakila.staff s
	order by s.staff_id
)	
select 
	staff_id,
	staff_last_name,
	last_rent_time,
	r6_customer_id,
	c.last_name customer_last_name
from results 
inner join sakila.customer c 
	on c.customer_id = r6_customer_id
;
