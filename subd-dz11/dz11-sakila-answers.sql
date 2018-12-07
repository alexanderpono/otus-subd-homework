#1. Введение в функции
#Посчитайте по таблице фильмов, в вывод также должен попасть ид фильма, название, описание и год выпуска
#пронумеруйте записи по названию фильма, так чтобы при изменении буквы алфавита нумерация начиналась заново
#посчитайте общее количество фильмов и выведете полем в этом же запросе
#посчитайте общее количество фильмов в зависимости от буквы начала называния фильма
#следующий ид фильма на следующей строки и включите в выборку
#предыдущий ид фильма
#названия фильма 2 строки назад
#Для этой задачи не обязательно писать аналог без функций

select 
	ROW_NUMBER() over w as rank1, 
	count(1) over w as count_rank, 
	sakila.film.film_id as id, 
	lead(sakila.film.film_id) over w as next_id, 
	lag(sakila.film.film_id) over w as prev_id, 
	lag(sakila.film.title, 2) over w as prev_name2, 
	(title), 
	(sakila.film.description) as descr, 
	(sakila.film.release_year) as year,
	(select count(1) from sakila.film) as count
from sakila.film 
window w as (partition by left(title, 1) order by left(title, 1))
order by sakila.film.film_id
;


#2. Вахтер Василий очень любит кино и свою работу, а тут у него оказался под рукой ваш прокат (ну представим что действие разворачивается лет 15-20 назад)
#Василий хочет посмотреть у вас все все фильмы при этом он хочет начать с худшего рейтинга и двигаться к шедеврам
#сделайте группы фильмов для Василия чтобы в каждой группе были разные жанры и фильмы сначала были с низким рейтингом, а затем с более высоким
#В результатах должен быть номер группы, ид фильма, название, и ид категории (жанра).

select 
	ntile(50) over (order by f.film_id) group_id,
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
order by f.film_id
;


#3.По каждому работнику проката выведете последнего клиента, которому сотрудник сдал что-то в прокат
#В результатах должны быть ид и фамилия сотрудника, ид и фамилия клиента, дата аренды
#Для этого задания нужно написать 2 варианта получения таких данных - с аналитической функцией и без нее. 
# - вариант без аналитической функции
select 
	s.staff_id as staff_id, 
	s.last_name staff_last_name,
	r.customer_id as customer_id,
	c.last_name customer_last_name,
	r.rental_id,
	r.rental_date
from sakila.staff s
inner join sakila.rental r
	on 
		r.staff_id = s.staff_id
		and r.rental_date = (
			select distinct r4.rental_date 
			from sakila.rental r4 
			where r4.staff_id=s.staff_id
			order by rental_date desc
			limit 1
		) 
inner join sakila.customer c 
	on c.customer_id = r.customer_id
order by staff_id, customer_id
;

# вариант с аналитической функцией
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
;


#4.Нужно выбрать последний просмотренный фильм по каждому актеру
#В результатах должно быть ид актера, его имя и фамилия, ид фильма, название и дата последней аренды.
#Для этого задания нужно написать 2 варианта получения таких данных - с аналитической функцией и без нее.
#Данные в обоих запросах (с оконными функциями и без) должны совпадать. 

#4 - вариант без аналитической функции
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


#4 - вариант с аналитической функцией
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
