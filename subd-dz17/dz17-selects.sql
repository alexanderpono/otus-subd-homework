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

SET @CURRENT_ARTICLE = 1; 
SELECT p.title, p.dt, p.post, p.referenced_post_id, COALESCE(reposted.title, 'NO_REPOSTED_ARTICLE') as referenced_title, pic.caption AS pic_caption, pic.file_name, u.name AS user_name 
FROM blog_db.post AS p 
LEFT OUTER JOIN blog_db.post AS reposted ON p.referenced_post_id = reposted.id 
INNER JOIN blog_db.picture AS pic ON pic.post_id = p.id 
INNER JOIN blog_db.`user` AS u ON p.author_user_id = u.id 
WHERE p.id = @CURRENT_ARTICLE 
;

SET @CURRENT_ARTICLE = 1; 
SELECT u.name, c.comment_text 
FROM blog_db.comment AS c 
INNER JOIN blog_db.`user` as u ON c.user_id = u.id 
WHERE c.post_id = @CURRENT_ARTICLE AND c.deleted=FALSE 
;

select 
	user_id,
	user_name,
	post_id,
	post_title,
	like_count
from (
	select 
		post_id, post_title, like_count, user_id, user_name,
		ROW_NUMBER() over (partition by user_id order by like_count desc) as rnk
	from(
		select 
			p.id as post_id,
			p.title as post_title,
			p.likes_count as like_count,
			u.id as user_id,
			u.name as user_name
		from blog_db.post p
		right outer join blog_db.`user` u
			on p.author_user_id = u.id
	) as post_likes_author
) as ranked_post_likes_author
where rnk <= 3
;

with user_id_name_rank as (
	select 
		u.id, 
		u.name,
		ROW_NUMBER() over (PARTITION BY u.id) as rank1
	from blog_db.`user` u
	inner join blog_db.post p
		on p.author_user_id = u.id
)
select DISTINCT
	uinr.id,
	uinr.name,
	LAST_VALUE(uinr.rank1) OVER (PARTITION BY uinr.id) as post_count
from user_id_name_rank uinr
limit 3
;

select 
	uvp.post_id, 
	p.title,
	sum(uvp.views_no) as total_views_count
from blog_db.user_viewed_post uvp
left join blog_db.post p
	on p.id = uvp.post_id
group by uvp.post_id
order by total_views_count desc
limit 2
;

SELECT p.id AS deleted_post_id, p.title AS post_title 
FROM blog_db.post AS p 
WHERE deleted = TRUE 
;

SELECT c.id, c.post_id, p.title AS post_title, c.user_id, c.comment_text, u.name AS user_name 
FROM blog_db.comment AS c 
INNER JOIN blog_db.post AS p 
   ON p.id = c.post_id 
INNER JOIN blog_db.`user` AS u 
   ON c.user_id = u.id 
WHERE c.deleted = TRUE 
;

call blog_db.del_from_post(1);

UPDATE blog_db.post
SET views_count=0, likes_count=0
WHERE 1
;

CALL blog_db.init_posts_precalculated();

CALL blog_db.user_viewed_post(2, 1);
CALL blog_db.user_likes_post(3, 3);
CALL blog_db.user_likes_post(4, 3);
CALL blog_db.user_unlikes_post(6, 7);
CALL blog_db.user_unlikes_post(5, 6);
CALL blog_db.user_likes_post(5, 6);








