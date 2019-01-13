#запрос 1а без использования аналитических функций

#Нужно выбрать последний просмотренный фильм по каждому актеру
#В результатах должно быть ид актера, его имя и фамилия, ид фильма, название и дата последней аренды.

explain
select 
	a.actor_id as actor_id1, 
	a.first_name as actor_first_name, 
	a.last_name as actor_last_name, 
	fa.film_id, 
	f.title as film_title,
	i.inventory_id,
	r.rental_id,
	r.rental_date as rental_date
from sakila.actor a
inner join sakila.film_actor fa
	on fa.actor_id = a.actor_id
inner join sakila.film f
	on f.film_id = fa.film_id
inner join sakila.inventory i
	on i.film_id = fa.film_id
inner join sakila.rental r
	on r.inventory_id = i.inventory_id
where 
	r.rental_date = (
		select  
			r1.rental_date as rental_date
		from sakila.actor a1
		inner join sakila.film_actor fa1
			on fa1.actor_id = a1.actor_id
		inner join sakila.film f1
			on f1.film_id = fa1.film_id
		inner join sakila.inventory i1
			on i1.film_id = fa1.film_id
		inner join sakila.rental r1
			on r1.inventory_id = i1.inventory_id
		where a1.actor_id = a.actor_id
		order by rental_date desc
		limit 1
	)
;



select DISTINCT 
	r1.rental_date as rental_date
from sakila.actor a1
inner join sakila.film_actor fa1
	on fa1.actor_id = a1.actor_id
inner join sakila.film f1
	on f1.film_id = fa1.film_id
inner join sakila.inventory i1
	on i1.film_id = fa1.film_id
inner join sakila.rental r1
	on r1.inventory_id = i1.inventory_id
where a1.actor_id = a.actor_id
order by rental_date desc
limit 1
;
