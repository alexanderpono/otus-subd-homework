#Топ 3 статьи с наибольшим количеством лайков по каждому пользователю
#план исходного запроса (до оптимизации)
explain
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



#план запроса после 1 этапа оптимизации
explain
select 
	user_id,
	user_name,
	post_id,
	post_title,
	like_count
from (
	select 
		*,
		ROW_NUMBER() over (partition by user_id order by like_count desc) as rnk
	from(
		select 
			p.id as post_id,
			p.title as post_title,
			(
				select count(1) 
				from blog_db.`like` l2
				where l2.post_id = p.id
			) as like_count,
			u.id as user_id,
			u.name as user_name
		from blog_db.post p
		right outer join blog_db.`user` u
			on p.author_user_id = u.id
	) as post_likes_author
) as ranked_post_likes_author
where rnk <= 3
;



#план запроса после 2 этапа оптимизации
explain
select 
	user_id,
	user_name,
	post_id,
	post_title,
	like_count
from (
	select 
		post_id, post_title, like_count, user_id, user_name,
		ROW_NUMBER() over (partition by user_id order by like_count desc) as rnk
	from(
		select 
			p.id as post_id,
			p.title as post_title,
			p.likes_count as like_count,
			u.id as user_id,
			u.name as user_name
		from blog_db.post p
		right outer join blog_db.`user` u
			on p.author_user_id = u.id
	) as post_likes_author
) as ranked_post_likes_author
where rnk <= 3
;




