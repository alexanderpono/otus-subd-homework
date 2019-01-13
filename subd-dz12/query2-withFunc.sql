#запрос 2 - вариант с аналитической функцией
#По каждому работнику проката выведете последнего клиента, которому сотрудник сдал что-то в прокат
#В результатах должны быть ид и фамилия сотрудника, ид и фамилия клиента, дата аренды
explain
select  
	staff_recent_customer.staff_id,
	staff_recent_customer.staff_last_name,
	staff_recent_customer.rental_date as last_rent_time,
	staff_recent_customer.customer_id r6_customer_id,
	staff_recent_customer.customer_last_name
from(
	with staff_recent_customers as (
		select * from (
			select 
				s.staff_id as staff_id, 
				s.last_name staff_last_name,
				r.customer_id as customer_id,
				c.last_name customer_last_name,
				r.rental_id,
				r.rental_date,
				rank() over (order by r.rental_date desc) as rank1
			from sakila.staff s
			inner join sakila.rental r
				on 
					r.staff_id = s.staff_id
			inner join sakila.customer c 
				on c.customer_id = r.customer_id
			) as results
		where rank1 <= 1
		order by staff_id, customer_id
	)
	select 
		staff_id,
		staff_last_name,
		customer_id,
		customer_last_name,
		rental_id,
		rental_date,
		ROW_NUMBER() over (PARTITION by staff_last_name order by customer_id) as rank2
	from staff_recent_customers
) as staff_recent_customer
where rank2 <= 1
;
