#использование подзапроса в FROM
#blog_db - Топ 3 статьи с наибольшим количеством лайков по каждому пользователю

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

explain

select 
	p.id as post_id,
	p.title as post_title,
	(
		select count(1) 
		from blog_db.`like` l2
		where l2.post_id = p.id
	) as like_count
from blog_db.post p
;			


explain

select 
	*, 
	ROW_NUMBER() over (partition by post_id) as rnk
from (
	select  
		p.id as post_id,
		p.title as post_title,
		l.id as like_id
	from blog_db.post p
	left outer join blog_db.`like` l
		on l.post_id = p.id
)	
as posts_likes
;			



explain
select  
	p.id as post_id,
	p.title as post_title,
	ROW_NUMBER() over (partition by p.id) as rnk
from blog_db.post p
left outer join blog_db.`like` l
	on l.post_id = p.id
;


explain
select distinct
	post_id,
	post_title,
	LAST_VALUE(posts_likes.rnk) over (partition by post_id) as rnk
from (	
	select  
		p.id as post_id,
		p.title as post_title,
		l.id as like_id,
		ROW_NUMBER() over (partition by p.id) as rnk
	from blog_db.post p
	left outer join blog_db.`like` l
		on l.post_id = p.id
) as posts_likes
;


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
			u.name as name
		from blog_db.post p
		inner join blog_db.`user` u
			on p.author_user_id = u.id
	) as post_likes_author
;



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
) as ordered_post_likes_author
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


create or replace view blog_db.v_most_popular_posts as
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


explain
select * 
from blog_db.v_most_popular_posts
;






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




