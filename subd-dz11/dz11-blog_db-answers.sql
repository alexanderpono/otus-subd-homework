#1. Топ 5 заказов в разрезе по разным городам
#адаптированная формулировка задачи к предметной области базы данных: 
#1. blog_db - Топ 3 статьи с наибольшим количеством лайков по каждому пользователю

#замечание:
#У вас для пользователя user2 отображается 4 статьи, а не три.

#исправленный вариант с другой оконной функцией, чтобы избежать отображение >3 статей для одного пользователя
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

#замечания:
#1) насколько количество лайков по каждой статье отличается от среднего количества лайков по всем статьям
   #Я бы хотел видеть в результате просто цифру на сколько количество лайков больше или меньше от среднего значения. 
   #Среднее у вас примерно 1.19. То есть, если в процентах: 5 лайков - 5*100/1.19 = 420%, 1 лайк - 1*100/1.19 = 84%, 
   #2 лайка - 2*100/1.19 = 168%
#2) а почему left outer join ? почему не inner join? p.author_user_id и l.post_id - not null
#3) И необходимость join blog_db.`like` не понятна.

#исправленное решение: 
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
	(select sum(like_count) from posts_like_count) as total_likes_count,
	(select count(1) from posts_like_count) as posts_count,
	(select total_likes_count / posts_count) as middle1,
	(select concat(format(like_count / middle1 * 100, 'N'), '%')) as percent_to_middle1
from posts_like_count
;

#заменил count на оконные функции, но пришлось добавить JOIN'ы. Получилось более громоздко и,
#возможно, работает несколько медленнее
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

#замечания:
#1) В вашем решении достаточно в подзапросе написать order by и limit 3, внешний запрос и не нужен
#2) Попробуйте переписать этот запрос без подзапросов. Это возможно как раз с использованием оконных функций.

#решение - шаг 1. Использовал order by и limit 3 
select 
	u.id, 
	u.name,
	(select count(1) from blog_db.post p where p.author_user_id = u.id) as post_count
from blog_db.`user` u
limit 3
;

#решение - шаг 2. заменяю count(1) на оконные функции
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



#4. Топ 2 самые новых новостей по темам
#адаптированная формулировка задачи к предметной области базы данных: 
#4. blog_db - Вывести 2 наиболее интересных статьи (просмотрены наибольшее количество раз)
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




