#blog-db MySQL8
#Доработана структура БД: 
#1) В таблице «user_viewed_post» добавлен составной индекс по полям post_id, user_id
#2) В таблице user тип поля "password" заменен с varchar(32) на BINARY(16) для хранения md5-хэшей в числовом виде и для устранения проблем с кодировками
#3) поле post.lead переименовано в post.lead1
#4)убрал  CONSTRAINT `fk_post_referenced_post_id`
#    FOREIGN KEY (`referenced_post_id`)
#    REFERENCES `blog_db`.`post` (`id`)
#    ON DELETE NO ACTION
#    ON UPDATE NO ACTION)
#    т.к. это ограничение не позволяет вставлять в таблицу записи, которые в поле referenced_post_id содержат 0
#    (т.е. вставлямая статья может не ссылаться ни на какую статью)


#2. запрос на Insert с использованием Select

INSERT INTO blog_db.comment(post_id, comment_text, user_id, deleted)
SELECT post_id, comment_text, user_id, deleted 
FROM blog_db.comment
WHERE post_id='1';


#3. Изменение данных UPDATE, UPDATE с использованием JOIN

UPDATE blog_db.comment
SET post_id = '2'
WHERE id IN(3,4,5,6);

UPDATE blog_db.comment
SET post_id = '3'
WHERE id > 6;

UPDATE blog_db.comment as c 
	JOIN blog_db.`user` AS u
	ON u.id = c.user_id
SET c.comment_text= CONCAT(c.comment_text, ' ', u.name) 
WHERE u.name='user2' AND c.post_id='3';


#4. Delete
DELETE FROM blog_db.comment
WHERE id=5;


#5. Merge (MySQL)
INSERT INTO blog_db.user_viewed_post(post_id, user_id, views_no, last_view_dt)
VALUES (3, 3, 1, CURDATE())
ON DUPLICATE KEY UPDATE views_no = views_no + 1;


#проверка TRIGGER `blog_db`.`user_viewed_post_BEFORE_INSERT` 
#у поста post.id=1 дата публикации (2018 год) - больше, чем вставляемая дата просмотра (2000 год) этой статьи
SET FOREIGN_KEY_CHECKS=1;
INSERT INTO blog_db.user_viewed_post(post_id, user_id, views_no, last_view_dt)
VALUES (1, 7, 1, '2000-01-01')
;

#проверка blog_db.like.CONSTRAINT `fk_like_post_id`   FOREIGN KEY (`post_id`)  REFERENCES `blog_db`.`post` (`id`)
#записи post.id=100 не существует
SET FOREIGN_KEY_CHECKS=1;
INSERT INTO blog_db.`like`(post_id, user_id, deleted) 
VALUES 
	(100, 6, FALSE)
;

#проверка blog_db.like.СONSTRAINT `fk_like_user_id`    FOREIGN KEY (`user_id`)    REFERENCES `blog_db`.`user` (`id`)
#записи user.id=100 не существует
SET FOREIGN_KEY_CHECKS=1;
INSERT INTO blog_db.`like`(post_id, user_id, deleted) 
VALUES 
	(4, 100, FALSE)
;

#проверка blog_db.comment.CONSTRAINT `fk_comment_post_id`     FOREIGN KEY (`post_id`)    REFERENCES `blog_db`.`post` (`id`)
#записи post.id=100 не существует
INSERT INTO blog_db.comment(post_id, comment_text, user_id, deleted) 
VALUES 
	(100, 'А мне - нравится!', 2, FALSE)
;

#проверка blog_db.comment.CONSTRAINT `fk_comment_user_id`    FOREIGN KEY (`user_id`)    REFERENCES `blog_db`.`user` (`id`)
#записи user.id=100 не существует
INSERT INTO blog_db.comment(post_id, comment_text, user_id, deleted) 
VALUES 
	(5, 'А мне - нравится!', 100, FALSE)
;

#проверка blog_db.picture.CONSTRAINT `fk_picture_1`    FOREIGN KEY (`post_id`)    REFERENCES `blog_db`.`post` (`id`)
#записи post.id=202 не существует
INSERT INTO `blog_db`.`picture` (post_id, file_name, caption, deleted)
VALUES 
	(202, '2.txt', 'caption', FALSE)
;

#проверка вставки в blog_db.post
INSERT INTO blog_db.post(post, dt, title, author_user_id, last_edit_dt, lead1, visible, referenced_post_id, deleted) 
VALUES 
	('text12', '2018-11-02', 'Супер название статьи 12', 5, '2018-11-02', 'Вводный текст к статье 12', TRUE, 0, FALSE)
;

#проверка вставки в blog_db.user
INSERT INTO `blog_db`.`user` (name, `password`, blocked)
VALUES 
	('superuser', '234234', FALSE)
;

#вывод публикации и связанных с ней сущностей, в т.ч. информации о состоянии "deleted" записей
select 
	p.id, 
	p.lead1, 
	p.post, 
	pic.caption, 
	pic.file_name pic_fName, 
	uvp.user_id uvp_user_id, 
	uvp.views_no,
	l.user_id like_user_id,
	c.comment_text,
	c.user_id comment_user_id,
	p.deleted p_deleted,
	pic.deleted pic_deleted,
	l.deleted l_deleted,
	c.deleted c_deleted
from blog_db.post p
left outer join blog_db.picture pic
	on pic.post_id = p.id
left outer join blog_db.user_viewed_post uvp
	on uvp.post_id = p.id
left outer join blog_db.`like` l
	on l.post_id = p.id
left outer join blog_db.comment c
	on c.post_id = p.id
where p.id = '1'
;


#проверка хранимых процедур
CALL `blog_db`.del_from_post(1);

#проверка хранимых процедур
CALL `blog_db`.del_from_picture(1);

#проверка хранимых процедур
CALL `blog_db`.del_from_picture(2);

#проверка хранимых процедур
CALL `blog_db`.del_from_comment(7);

