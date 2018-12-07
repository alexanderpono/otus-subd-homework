SET @ACTIVE_BLOG_USER_ID = 1;

SELECT p.id, p.title, p.lead, p.last_edit_dt, count(l.id) as likes_count FROM blog_db.post as p
INNER JOIN blog_db.like as l
	ON l.post_id = p.id
WHERE author_user_id = @ACTIVE_BLOG_USER_ID AND p.deleted=FALSE;


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


SELECT p.id, p.title, p.lead1, p.dt, 
	(SELECT COUNT(1) FROM blog_db.like as l WHERE l.post_id = p.id) as likes_count,
	(SELECT COALESCE(SUM(uvp.views_no), 0) FROM blog_db.user_viewed_post as uvp WHERE uvp.post_id = p.id) as views_count
FROM blog_db.post as p
WHERE author_user_id = '1' AND p.deleted=FALSE AND p.visible=TRUE
LEFT JOIN blog_db.picture as pic
	ON pic.post_id = p.id
ORDER BY p.dt DESC 
LIMIT 10
OFFSET 0
;

	COALESCE(pic.caption, 'no picture') as pic_name,
	COALESCE(pic.file_name, 'no picture') as pic_file_name 
