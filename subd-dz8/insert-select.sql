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

