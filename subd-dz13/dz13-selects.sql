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


