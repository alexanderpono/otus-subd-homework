SET @ACTIVE_BLOG_USER_ID = 1;

SELECT p.id, p.title, p.lead, p.last_edit_dt, count(l.id) as likes_count FROM blog_db.post as p
INNER JOIN blog_db.like as l
	ON l.post_id = p.id
WHERE author_user_id = @ACTIVE_BLOG_USER_ID AND p.deleted=FALSE;
