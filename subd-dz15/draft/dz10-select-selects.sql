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


explain
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

explain
	SELECT p.id, p.title, p.lead1, p.dt, p.author_user_id,
		(SELECT COUNT(1) FROM blog_db.`like` as l WHERE l.post_id = p.id) as likes_count,
		(SELECT COALESCE(SUM(uvp.views_no), 0) FROM blog_db.user_viewed_post as uvp WHERE uvp.post_id = p.id) as views_count 
	FROM blog_db.post as p
	WHERE p.deleted=FALSE AND p.visible=TRUE and p.author_user_id=1
	ORDER BY p.dt DESC 
;


explain
select 
	*,
	(SELECT COUNT(1) FROM blog_db.`like` as l WHERE l.post_id = post_info.id) as likes_count,
	(SELECT COALESCE(SUM(uvp.views_no), 0) FROM blog_db.user_viewed_post as uvp WHERE uvp.post_id = post_info.id) as views_count 
from(
	SELECT p.id, p.title, p.lead1, p.dt, p.author_user_id 
	FROM blog_db.post as p
	WHERE p.deleted=FALSE AND p.visible=TRUE and p.author_user_id=1
	ORDER BY p.dt DESC
) as post_info	
;


explain
select 
	*,
	(SELECT COUNT(1) FROM blog_db.`like` as l WHERE l.post_id = post_info.id) as likes_count,
	(SELECT COALESCE(SUM(uvp.views_no), 0) FROM blog_db.user_viewed_post as uvp WHERE uvp.post_id = post_info.id) as views_count, 
	COALESCE(pic.caption, 'no picture') as pic_name,
	COALESCE(pic.file_name, 'no picture') as pic_file_name 
from(
	SELECT p.id, p.title, p.lead1, p.dt, p.author_user_id 
	FROM blog_db.post as p
	WHERE p.deleted=FALSE AND p.visible=TRUE and p.author_user_id=1
) as post_info	
LEFT JOIN blog_db.picture as pic
	ON pic.post_id = post_info.id
ORDER BY post_info.dt DESC
;