select count(1) from film;

select * from film limit 10;


select row_number() over (order by film_id), film.*
from film 
order by film_id
limit 20;

select rank() over (order by film_id), film_id, title, film.description, film.release_year
from film 
order by film_id
limit 20;

select title, left(title, 2)
from film
order by film_id
limit 50;

select 
	ROW_NUMBER() over (partition by left(title, 1) order by film_id) as 'rank', 
	film_id as id, 
	title, 
	left(film.description, 10) as descr, 
	film.release_year as year
	#count(film.film_id)
from film 
order by film_id
limit 50;

select 
	DENSE_RANK() over (order by left(ANY_VALUE(title), 1)) as 'rank', 
	ANY_VALUE(film_id) as id, 
	ANY_VALUE(title), 
	ANY_VALUE(left(film.description, 10)) as descr, 
	ANY_VALUE(film.release_year) as year,
	count(film.film_id)
from film 
order by film_id
limit 50;

select 
	ROW_NUMBER() over w as rank1, 
	count(1) over w as count_rank, 
	film.film_id as id, 
	lead(film.film_id) over w as next_id, 
	lag(film.film_id) over w as prev_id, 
	lag(film.title, 2) over w as prev_name2, 
	(title), 
	(left(film.description, 10)) as descr, 
	(film.release_year) as year,
	(select count(1) from film) as count
from film 
window w as (partition by left(title, 1) order by left(title, 1))
order by film.film_id
;

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
	film.film_id as id, 
	lead(film.film_id) over w as next_id, 
	lag(film.film_id) over w as prev_id, 
	lag(film.title, 2) over w as prev_name2, 
	(title), 
	(film.description) as descr, 
	(film.release_year) as year,
	(select count(1) from film) as count
from film 
window w as (partition by left(title, 1) order by left(title, 1))
order by film.film_id
;


select f.film_id, f.title, f.rating, fc.category_id, c.name 
from film f
left outer join film_category fc 
	on fc.film_id = f.film_id
left outer join category c
	on c.category_id = fc.category_id
;

order by rating desc


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
from film f
inner join film_category fc 
	on fc.film_id = f.film_id
inner join category c
	on c.category_id = fc.category_id
order by f.film_id
;

select s.staff_id, s.first_name, s.last_name
from staff s
;

select *
from customer c
;

select *
from rental r
;

select r.rental_id, r.rental_date, r.customer_id, r.staff_id
from rental r
order by r.customer_id, r.rental_date desc
;

select r.rental_id, r.rental_date, r.customer_id, r.staff_id
from rental r
order by r.staff_id, r.rental_date desc
;

select 
	(r.rental_id), 
	(r.rental_date), 
	(r.customer_id), 
	(r.staff_id), 
	(select max(rental_date) from rental r2 where r2.staff_id=r.staff_id) m
from rental r
where 
	r.staff_id = 1
;
	
select 
	s.staff_id, 
	s.first_name, 
	s.last_name,
	(select max(rental_date) from rental r2 where r2.staff_id=s.staff_id) m
from staff s
;
 
#,
#	(select r2.rental_id from rental r2 where r2.staff_id=s.staff_id and r2.),

select 
	(r.rental_id), 
	(r.rental_date), 
	(r.customer_id), 
	(r.staff_id), 
	(select max(rental_date) from rental r2 where r2.staff_id=r.staff_id) m
from rental r
where 
	r.staff_id = 1
;

select max(rental_date) 
from rental r2 
where r2.staff_id=1
;

select 
	s.staff_id, 
	s.first_name, 
	s.last_name,
	(select max(rental_date) from rental r2 where r2.staff_id=s.staff_id) m,
	r.rental_id,
	r.rental_date,
	r.customer_id
from staff s
inner join rental r
	on r.staff_id = s.staff_id
;

select max(rental_date) 
from rental r2 
where r2.staff_id=1
;

select distinct r2.rental_date 
from rental r2 
where r2.staff_id=1
order by rental_date desc
limit 1
;

select 
	s.staff_id, 
	s.first_name, 
	s.last_name,
	(
		select distinct r3.rental_date 
		from rental r3 
		where r3.staff_id=1
		order by rental_date desc
		limit 1
	) m2,
	r.rental_id,
	r.rental_date,
	r.customer_id
from staff s
inner join rental r
	on r.staff_id = s.staff_id
;


select 
	s.staff_id, 
	s.last_name staff_last_name,
	(
		select distinct r3.rental_date 
		from rental r3 
		where r3.staff_id=s.staff_id
		order by rental_date desc
		limit 1
	) m2,
	r.rental_id,
	r.rental_date,
	r.customer_id
from staff s
inner join rental r
	on 
		r.staff_id = s.staff_id
		and r.rental_date = (
			select distinct r4.rental_date 
			from rental r4 
			where r4.staff_id=s.staff_id
			order by rental_date desc
			limit 1
		) 
	
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
from staff s
inner join rental r
	on 
		r.staff_id = s.staff_id
		and r.rental_date = (
			select distinct r4.rental_date 
			from rental r4 
			where r4.staff_id=s.staff_id
			order by rental_date desc
			limit 1
		) 
inner join customer c 
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
	from staff s
	inner join rental r
		on 
			r.staff_id = s.staff_id
	inner join customer c 
		on c.customer_id = r.customer_id
	) as results
where rank1 <= 1
order by staff_id, customer_id
;


select 
	a.actor_id as actor_id, 
	a.first_name as actor_first_name, 
	a.last_name as actor_last_name, 
	fa.film_id, 
	f.title as film_title,
	i.inventory_id,
	r.rental_id,
	r.rental_date as rental_date
from actor a
inner join film_actor fa
	on fa.actor_id = a.actor_id
inner join film f
	on f.film_id = fa.film_id
inner join inventory i
	on i.film_id = fa.film_id
inner join rental r
	on r.inventory_id = i.inventory_id
order by actor_id, rental_date desc	
;


select 
	a.actor_id as actor_id, 
	a.first_name as actor_first_name, 
	a.last_name as actor_last_name, 
	fa.film_id, 
	f.title as film_title,
	i.inventory_id,
	r.rental_id,
	r.rental_date as rental_date
from actor a
inner join film_actor fa
	on fa.actor_id = a.actor_id
inner join film f
	on f.film_id = fa.film_id
inner join inventory i
	on i.film_id = fa.film_id
inner join rental r
	on r.inventory_id = i.inventory_id
where a.actor_id = 140
order by actor_id, rental_date desc
;


select DISTINCT 
	r.rental_date as rental_date
from actor a
inner join film_actor fa
	on fa.actor_id = a.actor_id
inner join film f
	on f.film_id = fa.film_id
inner join inventory i
	on i.film_id = fa.film_id
inner join rental r
	on r.inventory_id = i.inventory_id
where a.actor_id = 199
order by rental_date desc
limit 1
;

select count(*)
from inventory
;

select 
	a.actor_id as actor_id, 
	a.first_name as actor_first_name, 
	a.last_name as actor_last_name, 
	fa.film_id, 
	f.title as film_title,
	i.inventory_id,
	r.rental_id,
	r.rental_date as rental_date
from actor a
inner join film_actor fa
	on fa.actor_id = a.actor_id
inner join film f
	on f.film_id = fa.film_id
inner join inventory i
	on i.film_id = fa.film_id
inner join rental r
	on r.inventory_id = i.inventory_id
where 
	a.actor_id = 4
	and r.rental_date = '2006-02-14 15:16:03'
order by actor_id, rental_date desc
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
from actor a
inner join film_actor fa
	on fa.actor_id = a.actor_id
inner join film f
	on f.film_id = fa.film_id
inner join inventory i
	on i.film_id = fa.film_id
inner join rental r
	on r.inventory_id = i.inventory_id
where 
	r.rental_date = (
		select DISTINCT 
			r1.rental_date as rental_date
		from actor a1
		inner join film_actor fa1
			on fa1.actor_id = a1.actor_id
		inner join film f1
			on f1.film_id = fa1.film_id
		inner join inventory i1
			on i1.film_id = fa1.film_id
		inner join rental r1
			on r1.inventory_id = i1.inventory_id
		where a1.actor_id = a.actor_id
		order by rental_date desc
		limit 1
	)
order by actor_id1
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
	from actor a
	left outer join film_actor fa
		on fa.actor_id = a.actor_id
	left outer join film f
		on f.film_id = fa.film_id
	left outer join inventory i
		on i.film_id = fa.film_id
	left outer join rental r
		on r.inventory_id = i.inventory_id
) as result1	
where rank1 <= 1
order by actor_id1
;


select distinct r4.rental_date 
from rental r4 
where r4.staff_id=s.staff_id
order by rental_date desc
limit 1
;

select 
	dense_rank() over (order by r1.rental_date desc) as rn,
	first_value(rental_id) over (partition by r1.rental_date) as first_val,
	lag(rental_id) over (partition by r1.rental_date) as lag1,
	r1.*  
from sakila.rental r1
order by rn
;


select count(1)
from sakila.rental
;

with rental2 as (
	select 
		rental1.rental_id, 
		rental1.staff_id, 
		rental1.rental_date, 
		rental1.inventory_id,
		rental1.customer_id
	from (
		select
			r.rental_id,
			r.staff_id,
			r.rental_date, 
			r.inventory_id,
			r.customer_id,
			ROW_NUMBER() over (partition by r.staff_id, r.rental_date order by r.staff_id, r.rental_date desc) as rn
		from sakila.rental r
		order by r.rental_date desc, rn, r.staff_id
	) as rental1
	where rn <= 1
	order by rental1.rental_date desc
)
select * from rental2;

#по каждому фильму - дата последнего просмотра
with film_last_view_date as (
	#по каждому инвентарному номеру - дату последнего просмотра
	with rental2 as (
		select 
			rental1.rental_id, 
			rental1.staff_id, 
			rental1.rental_date, 
			rental1.inventory_id,
			rental1.customer_id
		from (
			select
				r.rental_id,
				r.staff_id,
				r.rental_date, 
				r.inventory_id,
				r.customer_id,
				ROW_NUMBER() over (partition by r.staff_id, r.rental_date order by r.staff_id, r.rental_date desc) as rn
			from sakila.rental r
			order by r.rental_date desc, rn, r.staff_id
		) as rental1
		where rn <= 1
		order by rental1.rental_date desc
	)
	select 
		r.rental_id,
		r.staff_id,
		r.rental_date,
		r.inventory_id,
		r.customer_id,
		i.film_id,
		f.title as film_title
	from rental2 r
	inner join sakila.inventory i
		on i.inventory_id = r.inventory_id
	inner join sakila.film f
		on f.film_id = i.film_id
)
select * 
from film_last_view_date
;







#неправильно
with rental2 as (
	select 
		rental1.rental_id, 
		rental1.staff_id, 
		rental1.rental_date, 
		rental1.inventory_id,
		rental1.customer_id
	from (
		select
			r.rental_id,
			r.staff_id,
			r.rental_date, 
			r.inventory_id,
			r.customer_id,
			ROW_NUMBER() over (partition by r.staff_id, r.rental_date order by r.staff_id, r.rental_date desc) as rn
		from sakila.rental r
		order by r.rental_date desc, rn, r.staff_id
	) as rental1
	where rn <= 1
	order by rental1.rental_date desc
)
select 
	actor_id1,
	actor_first_name,  
	actor_last_name,  
	film_id,  
	film_title,  
	last_rental_date,
	rank1
from (
	select 
		a.actor_id as actor_id1, 
		a.first_name as actor_first_name, 
		a.last_name as actor_last_name, 
		fa.film_id, 
		f.title as film_title,
		i.inventory_id,
		r.rental_id,
		r.rental_date as last_rental_date,
		rank() over (partition by a.actor_id order by r.rental_date desc) as rank1
	from sakila.actor a
	left outer join sakila.film_actor fa
		on fa.actor_id = a.actor_id
	left outer join sakila.film f
		on f.film_id = fa.film_id
	left outer join sakila.inventory i
		on i.film_id = fa.film_id
	left outer join rental2 r
		on r.inventory_id = i.inventory_id
) as result1
where rank1 <= 10
;

order by actor_id1

select *
from sakila.rental r
where 
;


select distinct
	r.staff_id,
	r.rental_date 
from sakila.rental r
inner join sakila.rental r2
	on r.rental_id = r2.rental_id
order by r.rental_date desc, r.staff_id
;


#4 - вариант с аналитической функцией. Вывести для каждого актера только один фильм, посмотренный последним
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





#############
#2. Насколько зарплата конкретного человека отличается от средней зарплаты (или насколько чек отличается от среднего чека) 
#адаптированная формулировка задачи к предметной области базы данных: 
#2. blog_db - насколько количество лайков по каждой статье отличается от среднего количества лайков по всем статьям
with posts_like_count as (
select DISTINCT 
	p.id as post_id,
	p.title as post_title,
	(
		select count(1) 
		from blog_db.`like` l2
		where l2.post_id = p.id
	) as like_count
from blog_db.post p
)
select 
	*, 
	(select sum(like_count) from posts_like_count) as sum1,
	(select count(1) from posts_like_count) as cnt1,
	(select sum1 / cnt1) as middle1,
	(select concat(format(like_count / middle1 * 100, 'N'), '%')) as percent_to_middle1
from posts_like_count
;

#2. старый запрос
select 
	*, 
	percent_rank() over (order by like_count desc) as percent_rank1,
	CUME_DIST() over (order by like_count desc) as cume_dist1
from (
	select DISTINCT 
		u.id as user_id,
		u.name as user_name,
		p.id as post_id,
		p.title as post_title,
		(
			select count(1) 
			from blog_db.`like` l2
			where l2.post_id = l.post_id
		) as like_count
	from blog_db.`user` u
	left outer join blog_db.post p
		on p.author_user_id = u.id
	left outer join blog_db.`like` l
		on l.post_id = p.id
) as results	
order by post_id	
;


#3. Выберите 5 лучших продавцов (работников, водителей) по сумме проданного.
#адаптированная формулировка задачи к предметной области базы данных: 
#3. blog_db - 3 наиболее активных автора (написали наибольшее число статей)
select 
	*,
	dense_rank() over (order by post_count desc) as rnk
from(
	select 
		u.id, 
		u.name,
		(select count(1) from blog_db.post p where p.author_user_id = u.id) as post_count
	from blog_db.`user` u
) as results1
limit 3
;


#старый запрос:
select * from(
	select 
		*, 
		rank() over (partition by user_id order by like_count desc) as rnk
	from (
		select DISTINCT 
			u.id as user_id,
			u.name as user_name,
			p.id as post_id,
			p.title as post_title,
			(
				select count(1) 
				from `like` l2
				where l2.post_id = l.post_id
			) as like_count
		from `user` u
		left outer join post p
			on p.author_user_id = u.id
		left outer join `like` l
			on l.post_id = p.id
	) as result
	order by user_id, like_count desc
) as result2
where rnk <= 3
;






select * from(
	select 
		*,
		dense_rank() over (order by post_count desc) as rnk
	from(
		select 
			u.id, 
			u.name,
			(select count(1) from blog_db.post p where p.author_user_id = u.id) as post_count
		from blog_db.`user` u
	) as results1
) as results2
where rnk <= 3
;


#4. Топ 2 самые новых новостей по темам
#адаптированная формулировка задачи к предметной области базы данных: 
#4. blog_db - Вывести 2 наиболее интересных статьи (просмотрены наибольшее количество раз)
#4. новый запрос
select 
	uvp.post_id, 
	p.title,
	sum(uvp.views_no) as total_views_count
from blog_db.user_viewed_post uvp
left join blog_db.post p
	on p.id = uvp.post_id
group by uvp.post_id
order by total_views_count desc
limit 2
;


#4. старый запрос
select * from(
	select 
		*,
		dense_rank() over(order by total_views_count desc) as rnk
	from (
		select 
			uvp.post_id, 
			p.title,
			sum(uvp.views_no) as total_views_count
		from blog_db.user_viewed_post uvp
		left outer join blog_db.post p
			on p.id = uvp.post_id
		group by uvp.post_id
	) as results1
	order by total_views_count desc
) as results2
where rnk <= 2 
;

#вычисление общего количества записей через оконные функции
select 
tbl1.film_id,
tbl1.title,
LAST_VALUE(rn) over (partition by tbl1.col1) as count
from (
	select 
		f.film_id, 
		f.title,
		ROW_NUMBER() over (order by f.film_id) as rn,
		(select 1) as col1
	from sakila.film f
) as tbl1
;

#прямой запрос count для вычисления общего количества записей
select 
	f.film_id, 
	f.title,
	(select count(1) from sakila.film) as count
from sakila.film f
window w as (order by f.film_id)
;



LAST_VALUE(rn) over (partition by tbl1.col1) as lv2


		(select count(1) from sakila.film) as count,
window w2 as (partition by tbl1.col1 order by tbl1.film_id)



#сложный запрос с вычисление количества записей в лоб
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
	count,
	LAST_VALUE(rank2) over (partition by results.anchor) as count2
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
		(select count(1) from sakila.film) as count,
		ROW_NUMBER() over (order by film_id) as rank2,
		(select 1) as anchor
	from sakila.film 
	window w as (partition by left(title, 1) order by left(title, 1))
	order by sakila.film.film_id
	) as results
	window w as (partition by left(title, 1) order by left(title, 1))
;


#сложный запрос с вычислением количества записей при помощи оконных функций
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
 