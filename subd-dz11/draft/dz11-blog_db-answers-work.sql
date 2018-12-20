#1. Топ 5 заказов в разрезе по разным городам
#адаптированная формулировка задачи к предметной области базы данных: 
#1. blog_db - Топ 3 статьи с наибольшим количеством лайков по каждому пользователю
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


#2. Насколько зарплата конкретного человека отличается от средней зарплаты (или насколько чек отличается от среднего чека) 
#адаптированная формулировка задачи к предметной области базы данных: 
#2. blog_db - насколько количество лайков по каждой статье отличается от среднего количества лайков по всем статьям
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
#3. новый запрос 
select 
	u.id, 
	u.name,
	(select count(1) from blog_db.post p where p.author_user_id = u.id) as post_count
from blog_db.`user` u
limit 3
;


#3. старый запрос
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





