INSERT INTO comment(post_id, comment_text, user_id, deleted)
SELECT post_id, comment_text, user_id, deleted 
FROM comment
WHERE post_id='1';

UPDATE comment
SET post_id = '2'
WHERE id IN(3,4,5,6);

UPDATE comment
SET post_id = '3'
WHERE id > 6;

UPDATE comment as c 
	JOIN `user` AS u
	ON u.id = c.user_id
SET c.comment_text= CONCAT(c.comment_text, ' ', u.name) 
WHERE u.name='user2' AND c.post_id='3';

SELECT MAX(id) FROM comment;

SELECT * FROM comment 
WHERE id=(SELECT MAX(id) FROM comment);


DELETE FROM comment
WHERE id=11;

