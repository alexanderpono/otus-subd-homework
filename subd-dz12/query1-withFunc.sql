#запрос 1б использованием аналитической функции

#Нужно выбрать последний просмотренный фильм по каждому актеру
#В результатах должно быть ид актера, его имя и фамилия, ид фильма, название и дата последней аренды.

EXPLAIN
select * from (
	select 
		a.actor_id as actor_id1, 
		a.first_name as actor_first_name, 
		a.last_name as actor_last_name, 
		fa.film_id, 
		f.title as film_title,
		i.inventory_id,
		r.rental_id,
		r.rental_date as rental_date,
		rank() over (partition by a.actor_id order by r.rental_date desc) as rank1
	from sakila.actor a
	inner join sakila.film_actor fa
		on fa.actor_id = a.actor_id
	inner join sakila.film f
		on f.film_id = fa.film_id
	inner join sakila.inventory i
		on i.film_id = fa.film_id
	inner join sakila.rental r
		on r.inventory_id = i.inventory_id
) as result1	
where rank1 <= 1
order by actor_id1
;

