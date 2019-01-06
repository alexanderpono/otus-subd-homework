#использование подзапроса в SELECT
#Получить список анонсов статей всех пользователей по убыванию даты/времени
#к анонсу статьи добавить: 
#- сколько лайков собрала статья
#- сколько просмотров собрала статья
#- картинку к статье (если есть)
create or replace view blog_db.v_announces as
	SELECT p.id, p.title, p.lead1, p.dt, p.author_user_id,
		(SELECT COUNT(1) FROM blog_db.`like` as l WHERE l.post_id = p.id) as likes_count,
		(SELECT COALESCE(SUM(uvp.views_no), 0) FROM blog_db.user_viewed_post as uvp WHERE uvp.post_id = p.id) as views_count,
		COALESCE(pic.caption, 'no picture') as pic_name,
		COALESCE(pic.file_name, 'no picture') as pic_file_name 
	FROM blog_db.post as p
	LEFT JOIN blog_db.picture as pic
		ON pic.post_id = p.id
	WHERE p.deleted=FALSE AND p.visible=TRUE
	ORDER BY p.dt DESC 
;
#Получить список анонсов статей указанного пользователя по убыванию даты/времени
select * 
from blog_db.v_announces v
where author_user_id = 1
;


#использование подзапроса в WHERE
create or replace view blog_db.v_simple_where as
	select * 
	from blog_db.`user` u
	where u.id in (
		select id 
		from blog_db.`user`
		where id>=2 and id<=5
	)
;
select *
from blog_db.v_simple_where
;


#использование подзапроса в FROM
#blog_db - Топ 3 статьи с наибольшим количеством лайков по каждому пользователю
create or replace view blog_db.v_most_popular_posts as
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

select *
from blog_db.v_most_popular_posts
;

