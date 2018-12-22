#1. Топ 5 заказов в разрезе по разным городам
#адаптированная формулировка задачи к предметной области базы данных: 
#1. blog_db - Топ 3 статьи с наибольшим количеством лайков по каждому пользователю

#У вас для пользователя user2 отображается 4 статьи, а не три.
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
				from blog_db.`like` l2
				where l2.post_id = l.post_id
			) as like_count
		from blog_db.`user` u
		left outer join blog_db.post p
			on p.author_user_id = u.id
		left outer join blog_db.`like` l
			on l.post_id = p.id
	) as result
	order by user_id, like_count desc
) as result2
where rnk <= 3
;

#вариант с другой оконной функцией, чтобы избежать отображение >3 статей для одного пользователя
select * from(
	select 
		*, 
		ROW_NUMBER() over (partition by user_id order by like_count desc) as rnk
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
	) as result
	order by user_id, like_count desc
) as result2
where rnk <= 3
;


#2. Насколько зарплата конкретного человека отличается от средней зарплаты (или насколько чек отличается от среднего чека) 
#адаптированная формулировка задачи к предметной области базы данных: 
#2. blog_db - насколько количество лайков по каждой статье отличается от среднего количества лайков по всем статьям

#первая версия запроса
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


#вторая версия запроса
#1) убрал join blog_db.`like`, т.к. это лишняя операция 
#2) посчитал в 
#		sum1 - общее количество лайков, 
#		cnt1 - общее количество статей,
#		middle1 - среднее арифметическое количество лайков на статью
#		percent_to_middle - отношение количества лайков на статье к среднему значению в процентах   
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


#третья версия запроса - уйти от count()
#внутренний запрос
select 
	posts_like_count_lineno.id,
	posts_like_count_lineno.title,
	posts_like_count_lineno.like_count,
	LAST_VALUE(line_no) over (PARTITION BY posts_like_count_lineno.anchor) as posts_count
from (
	with posts_like_count_tmp as(
		select DISTINCT
			post_id,
			LAST_VALUE(rank1) over (PARTITION BY post_id) as like_count
		from (
			select  
				p.id as post_id,
				ROW_NUMBER() over (PARTITION BY p.id) as rank1
			from blog_db.post p
			inner join blog_db.`like` as l
				on l.post_id = p.id
		) as sss
	)
	select 
		p.id,
		p.title,
		(SELECT IF (plc.like_count IS NOT NULL, plc.like_count, '0')) as like_count,
		ROW_NUMBER() over (order by p.id) as line_no,
		(select 1) as anchor
	from blog_db.post p	
	left outer join posts_like_count_tmp plc
		on plc.post_id = p.id
) as posts_like_count_lineno
;



#третья версия запроса - уйти от count() - ВСЕ В СБОРЕ
with posts_like_count as(
	select 
		posts_like_count_lineno.id,
		posts_like_count_lineno.title,
		posts_like_count_lineno.like_count,
		LAST_VALUE(line_no) over (PARTITION BY posts_like_count_lineno.anchor) as posts_count
	from (
		with posts_like_count_tmp as(
			select DISTINCT
				post_id,
				LAST_VALUE(rank1) over (PARTITION BY post_id) as like_count
			from (
				select  
					p.id as post_id,
					ROW_NUMBER() over (PARTITION BY p.id) as rank1
				from blog_db.post p
				inner join blog_db.`like` as l
					on l.post_id = p.id
			) as sss
		)
		select 
			p.id,
			p.title,
			(SELECT IF (plc.like_count IS NOT NULL, plc.like_count, '0')) as like_count,
			ROW_NUMBER() over (order by p.id) as line_no,
			(select 1) as anchor
		from blog_db.post p	
		left outer join posts_like_count_tmp plc
			on plc.post_id = p.id
	) as posts_like_count_lineno
)	
select 
	*, 
	(select sum(like_count) from posts_like_count) as total_likes_count,
	(select total_likes_count / posts_count) as middle1,
	(select concat(format(like_count / middle1 * 100, 'N'), '%')) as percent_to_middle1
from posts_like_count
;






#3. Выберите 5 лучших продавцов (работников, водителей) по сумме проданного.
#адаптированная формулировка задачи к предметной области базы данных: 
#3. blog_db - 3 наиболее активных автора (написали наибольшее число статей)
#3. версия запроса №2 
select 
	u.id, 
	u.name,
	(select count(1) from blog_db.post p where p.author_user_id = u.id) as post_count
from blog_db.`user` u
limit 3
;

#3. версия запроса №3 
with user_id_name_rank as (
	select 
		u.id, 
		u.name,
		ROW_NUMBER() over (PARTITION BY u.id) as rank1
	from blog_db.`user` u
	inner join blog_db.post p
		on p.author_user_id = u.id
)
select DISTINCT
	uinr.id,
	uinr.name,
	LAST_VALUE(uinr.rank1) OVER (PARTITION BY uinr.id) as post_count
from user_id_name_rank uinr
limit 3
;




#3. версия запроса №1
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





