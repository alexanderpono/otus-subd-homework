#1. Введение в функции
#Посчитайте по таблице фильмов, в вывод также должен попасть ид фильма, название, описание и год выпуска
#пронумеруйте записи по названию фильма, так чтобы при изменении буквы алфавита нумерация начиналась заново
#посчитайте общее количество фильмов и выведете полем в этом же запросе
#посчитайте общее количество фильмов в зависимости от буквы начала называния фильма
#следующий ид фильма на следующей строки и включите в выборку
#предыдущий ид фильма
#названия фильма 2 строки назад
#Для этой задачи не обязательно писать аналог без функций

#замечание: 
#Все хорошо, но (select count(1) from sakila.film) надо тоже через аналитическую функцию

#исправленный вариант:
select 
	rank1, 
	LAST_VALUE(rank1) over w as count_rank,
	id,
	next_id,
	prev_id,
	prev_name2,
	title,
	descr,
	year,
	LAST_VALUE(rank2) over (partition by results.anchor) as count
from (
	select 
		ROW_NUMBER() over w as rank1, 
		sakila.film.film_id as id, 
		lead(sakila.film.film_id) over w as next_id, 
		lag(sakila.film.film_id) over w as prev_id, 
		lag(sakila.film.title, 2) over w as prev_name2, 
		(title), 
		(sakila.film.description) as descr, 
		(sakila.film.release_year) as year,
		ROW_NUMBER() over (order by film_id) as rank2,
		(select 1) as anchor
	from sakila.film 
	window w as (partition by left(title, 1) order by left(title, 1))
	order by sakila.film.film_id
	) as results
	window w as (partition by left(title, 1) order by left(title, 1))
;



#2. Вахтер Василий очень любит кино и свою работу, а тут у него оказался под рукой ваш прокат (ну представим что действие разворачивается лет 15-20 назад)
#Василий хочет посмотреть у вас все все фильмы при этом он хочет начать с худшего рейтинга и двигаться к шедеврам
#сделайте группы фильмов для Василия чтобы в каждой группе были разные жанры и фильмы сначала были с низким рейтингом, а затем с более высоким
#В результатах должен быть номер группы, ид фильма, название, и ид категории (жанра).

#замечание:
#Сортировка должна быть не по film.id внутри окна

#доработанный запрос по замечаниям:
select 
	ntile(50) over (order by f.rating desc) group_id,
	f.film_id,
	f.title, 
	f.rating, 
	fc.category_id, 
	c.name category_name
from sakila.film f
inner join sakila.film_category fc 
	on fc.film_id = f.film_id
inner join sakila.category c
	on c.category_id = fc.category_id
order by group_id, f.rating desc
;


#3.По каждому работнику проката выведете последнего клиента, которому сотрудник сдал что-то в прокат
#В результатах должны быть ид и фамилия сотрудника, ид и фамилия клиента, дата аренды
#Для этого задания нужно написать 2 варианта получения таких данных - с аналитической функцией и без нее. 

#замечание:
#Попробуйте переделать так, чтобы для одного работника был только один клиент.

#3 версия без аналитической функции - новый вариант #1 (на одного сотрудника отображать только одного последнего клиента)
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
	) as r6_customer_id,
	(
		select c.last_name 
		from sakila.customer c 
		where c.customer_id = r6_customer_id
		limit 1
	) as customer_last_name
from sakila.staff s
order by s.staff_id
;


#3 версия без аналитической функции - новый вариант #2 (на одного сотрудника отображать только одного последнего клиента)
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


#3 вариант с аналитической функцией. Для каждого сотрудника - только один клиент
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


#4.Нужно выбрать последний просмотренный фильм по каждому актеру
#В результатах должно быть ид актера, его имя и фамилия, ид фильма, название и дата последней аренды.
#Для этого задания нужно написать 2 варианта получения таких данных - с аналитической функцией и без нее.
#Данные в обоих запросах (с оконными функциями и без) должны совпадать. 

#замечания:
# 1) Попробуйте также вывести один фильм для актера.
# 2) И в #3 и в #4 вы делаете JOIN всех таблиц внутри подзапроса, а потом фильтруете, где RANK <=1 - это обычно работает медленнее

#исправленные варианты (по замечанию №2 не исправлял)
#4 - вариант без аналитической функции. Для каждого актера выводится несколько фильмов, у которых одинаковые самые последние даты просмотра
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
	)
;

#4 - старый вариант с аналитической функцией - Для каждого актера выводится несколько фильмов, у которых одинаковые самые последние даты просмотра
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
	left outer join sakila.film_actor fa
		on fa.actor_id = a.actor_id
	left outer join sakila.film f
		on f.film_id = fa.film_id
	left outer join sakila.inventory i
		on i.film_id = fa.film_id
	left outer join sakila.rental r
		on r.inventory_id = i.inventory_id
) as result1	
where rank1 <= 1
order by actor_id1
;


#4 - вариант с аналитической функцией. Вывести для каждого актера только один фильм, посмотренный последним
#(по замечанию №2 не исправлял)
select  
	actor_id1, 
	actor_first_name,
	actor_last_name,
	film_id,
	film_title,
	rental_date
from (
	with actor_last_views as (
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
		left outer join sakila.film_actor fa
			on fa.actor_id = a.actor_id
		left outer join sakila.film f
			on f.film_id = fa.film_id
		left outer join sakila.inventory i
			on i.film_id = fa.film_id
		left outer join sakila.rental r
			on r.inventory_id = i.inventory_id
	) as result1	
	where rank1 <= 1
	order by actor_id1
	)
	select 
		actor_id1, 
		actor_first_name,
		actor_last_name,
		film_id,
		film_title,
		rental_date,
		ROW_NUMBER() over (partition by actor_first_name, actor_last_name order by actor_first_name, actor_last_name) as rank2
	from actor_last_views
) as actor_last_views_with_rank
where rank2 <= 1
;

