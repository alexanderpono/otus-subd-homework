# 3.4 Для административного интерфейса - получить список удаленных статей 
create or replace view blog_db.v_deleted_posts as
	SELECT p.id AS deleted_post_id, p.title AS post_title
	FROM blog_db.post AS p
	WHERE deleted = TRUE
;

select *
from blog_db.v_deleted_posts
;

# 3.5 Для административного интерфейса - получить список удаленных комментариев к статьям
create or replace view blog_db.v_deleted_comments as
	SELECT c.id, c.post_id, p.title AS post_title, c.user_id, c.comment_text, u.name AS user_name
	FROM blog_db.comment AS c
	INNER JOIN blog_db.post AS p
		ON p.id = c.post_id
	INNER JOIN blog_db.`user` AS u
		ON c.user_id = u.id
	WHERE c.deleted = TRUE
;

select *
from blog_db.v_deleted_comments
;


-- -----------------------------------------------------
-- Schema blog_web
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `blog_web` ;
CREATE SCHEMA IF NOT EXISTS `blog_web` DEFAULT CHARACTER SET utf8 collate utf8_general_ci;
-- USE `blog_db` ;

create or replace view blog_web.v_announces as
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

create or replace view blog_web.v_post as
	SELECT 
		p.title, 
		p.dt, 
		p.post, 
		p.referenced_post_id, 
		COALESCE(reposted.title, 'NO_REPOSTED_ARTICLE') as referenced_title, 
		COALESCE(pic.caption, 'no picture') as pic_caption,
		COALESCE(pic.file_name, 'no picture') as pic_file_name, 
		u.name AS user_name,
		p.id
	FROM blog_db.post AS p
	LEFT OUTER JOIN blog_db.post AS reposted
		ON p.referenced_post_id = reposted.id
	LEFT OUTER JOIN blog_db.picture AS pic
		ON pic.post_id = p.id
	LEFT OUTER JOIN blog_db.`user` AS u
		ON p.author_user_id = u.id
;

create or replace view blog_web.v_comments_for_posts as
	SELECT u.name, c.comment_text, c.post_id
	FROM blog_db.comment AS c
	INNER JOIN blog_db.`user` as u
		ON c.user_id = u.id
	WHERE c.deleted=FALSE
;



#1.	
#Получить список анонсов статей указанного пользователя по убыванию даты/времени постранично
#к анонсу статьи добавить: 
#- сколько лайков собрала статья
#- сколько просмотров собрала статья
#- картинку к статье (если есть)
select v.id, v.title, v.lead1, v.dt, v.likes_count, v.views_count, v.pic_name,  v.pic_file_name 
from blog_web.v_announces v
where author_user_id = 1
;

#3.2 на странице просмотра одной статьи блога - вывести указанную статью: название, дату, текст, картинку, имя автора, id перепечатываемой статьи
select *
from blog_web.v_post v
where v.id = 1
;

#3.3 на странице просмотра одной статьи блога - вывести список комментариев. 
#для комментария показать: автора, текст комментария. У комментариев нет тредов: один уровень вложенности, только к статье
select *
from blog_web.v_comments_for_posts v
where v.post_id = 1
;

update blog_web.v_comments_for_posts
set comment_text='Красивое фото!'
where post_id=1 AND name='user2'
;




#-----------------------------------------------------------------------------------------
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

