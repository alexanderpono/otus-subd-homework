#исходный запрос в виде представления:
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
#Использование представления - получить список анонсов статей указанного пользователя по убыванию даты/времени
select * 
from blog_db.v_announces v
where author_user_id = 1
;

#план исходного запроса
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



#план доработанного запроса после итерации доработки-1
explain
select 
	post_info.id, 
	post_info.title, 
	post_info.lead1, 
	post_info.dt, 
	post_info.author_user_id, 
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


#план доработанного запроса после итерации доработки-2
explain
select 
	post_info.id, 
	post_info.title, 
	post_info.lead1, 
	post_info.dt, 
	post_info.author_user_id, 
	post_info.likes_count, 
	post_info.views_count, 
	COALESCE(pic.caption, 'no picture') as pic_name,
	COALESCE(pic.file_name, 'no picture') as pic_file_name 
from(
	SELECT p.id, p.title, p.lead1, p.dt, p.author_user_id, p.likes_count, p.views_count 
	FROM blog_db.post as p
	WHERE p.deleted=FALSE AND p.visible=TRUE and p.author_user_id=1
) as post_info	
LEFT JOIN blog_db.picture as pic
	ON pic.post_id = post_info.id
ORDER BY post_info.dt DESC
;
