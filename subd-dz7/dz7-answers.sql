#1.	Запрос с LEFT JOIN. 
#Получить список анонсов статей указанного пользователя по убыванию даты/времени постранично
#к анонсу статьи добавить: 
#- сколько лайков собрала статья
#- сколько просмотров собрала статья
#- картинку к статье (если есть)
SET @ACTIVE_BLOG_USER_ID = 1;

SELECT p.id, p.title, p.lead1, p.dt, 
	(SELECT COUNT(1) FROM blog_db.like as l WHERE l.post_id = p.id) as likes_count,
	(SELECT COALESCE(SUM(uvp.views_no), 0) FROM blog_db.user_viewed_post as uvp WHERE uvp.post_id = p.id) as views_count,
	COALESCE(pic.caption, 'no picture') as pic_name,
	COALESCE(pic.file_name, 'no picture') as pic_file_name 
FROM blog_db.post as p
LEFT JOIN blog_db.picture as pic
	ON pic.post_id = p.id
WHERE author_user_id = @ACTIVE_BLOG_USER_ID AND p.deleted=FALSE AND p.visible=TRUE
ORDER BY p.dt DESC 
LIMIT 10
OFFSET 0
;


#2. запрос с INNER JOIN
#получить список статей и имен их авторов
SELECT p.id as post_id, p.title as post_title, u.name as author_name, u.id as user_id
FROM blog_db.post as p 
INNER JOIN blog_db.`user` as u 
	ON p.author_user_id = u.id
;



#3. запросы с WHERE
#для вывода на главной странице блога - постранично вывести список анонсов статей указанного пользователя по убыванию даты/времени
#3.1. см. запрос "1.	Запрос с LEFT JOIN"


#3.2 на странице просмотра одной статьи блога - вывести указанную статью: название, дату, текст, картинку, имя автора, id перепечатываемой статьи
SET @CURRENT_ARTICLE = 1;
SELECT p.title, p.dt, p.post, p.referenced_post_id, COALESCE(reposted.title, 'NO_REPOSTED_ARTICLE') as referenced_title, pic.caption AS pic_caption, pic.file_name, u.name AS user_name
FROM blog_db.post AS p
LEFT OUTER JOIN blog_db.post AS reposted
	ON p.referenced_post_id = reposted.id
INNER JOIN blog_db.picture AS pic
	ON pic.post_id = p.id
INNER JOIN blog_db.`user` AS u
	ON p.author_user_id = u.id
WHERE p.id = @CURRENT_ARTICLE
;


#3.3 на странице просмотра одной статьи блога - вывести список комментариев. 
#для комментария показать: автора, текст комментария. У комментариев нет тредов: один уровень вложенности, только к статье
SET @CURRENT_ARTICLE = 1;
SELECT u.name, c.comment_text
FROM blog_db.comment AS c
INNER JOIN blog_db.`user` as u
	ON c.user_id = u.id
WHERE c.post_id = @CURRENT_ARTICLE AND c.deleted=FALSE
;



# 3.4 Для административного интерфейса - получить список удаленных статей 
SELECT p.id AS deleted_post_id, p.title AS post_title
FROM blog_db.post AS p
WHERE deleted = TRUE
;


# 3.5 Для административного интерфейса - получить список удаленных комментариев к статьям
SELECT c.id, c.post_id, p.title AS post_title, c.user_id, c.comment_text, u.name AS user_name
FROM blog_db.comment AS c
INNER JOIN blog_db.post AS p
	ON p.id = c.post_id
INNER JOIN blog_db.`user` AS u
	ON c.user_id = u.id
WHERE c.deleted = TRUE
;



