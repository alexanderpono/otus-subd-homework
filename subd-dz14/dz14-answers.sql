-- план запроса для проверки, что составной индекс "user_viewed_post.post_id_user_id_UNIQUE" по паре полей (post_id, user_id) работает для поля post_id:
explain
select 
	p.id, p.post,
	(SELECT COALESCE(SUM(uvp.views_no), 0) FROM blog_db.user_viewed_post as uvp WHERE uvp.post_id = p.id) as views_count
from blog_db.post p
;
