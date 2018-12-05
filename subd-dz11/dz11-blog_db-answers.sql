#blog_db - топ 3 статьи с наибольшим количеством лайков по каждому пользователю
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
