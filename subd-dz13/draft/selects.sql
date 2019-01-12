#сброс счетчиков лайков и просмотров статей в таблице post
update blog_db.post
set views_count=0, likes_count=0
where 1
;

#актуализация счетчиков лайков и просмотров статей в таблице post
call blog_db.init_posts_precalculated();



CALL blog_db.user_viewed_post(2, 1);

CALL blog_db.user_likes_post(3, 3);

CALL blog_db.user_likes_post(4, 3);


CALL blog_db.user_unlikes_post(6, 7);

CALL blog_db.user_unlikes_post(5, 6);

CALL blog_db.user_likes_post(5, 6);


select 
	p.id, 
	p.likes_count, 
	p.views_count,
	(select count(1) from blog_db.`like` l where l.post_id=p.id) as likes_count,
	(SELECT COALESCE(SUM(uvp.views_no), 0) FROM blog_db.user_viewed_post as uvp WHERE uvp.post_id = p.id) as views_count
from blog_db.post p
;

call blog_db.init_posts_precalculated();


UPDATE blog_db.post 
SET `views_count` = 10, `likes_count` = 20
WHERE `id` = 1
;

select * 
from blog_db.`like` l 
where l.post_id = 1 AND l.user_id=2
;

exists 


if not exists(
	select * 
	from blog_db.`like`  
	where post_id = 1 AND user_id=2
) then
	insert into blog_db.`like`(post_id, user_id)
	values(1, 2)
end if;


insert into blog_db.`like`(post_id, user_id)
select * from (select 1, 6) as tmp  
where not exists(
	select id from blog_db.`like` where post_id = 1 AND user_id=6
)
;


select 1  
where not exists(
	select id from blog_db.`like` where post_id = 1 AND user_id=2
)
;