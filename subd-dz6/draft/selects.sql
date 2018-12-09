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

CALL del_from_post(1)
;

CALL del_from_picture('1')
;


DROP PROCEDURE IF EXISTS `del_from_post`;
DROP PROCEDURE IF EXISTS `debug_msg`;
DELIMITER $$
CREATE PROCEDURE debug_msg(enabled INTEGER, msg VARCHAR(255))
BEGIN
  IF enabled THEN BEGIN
    select concat("** ", msg) AS '** DEBUG:';
  END; END IF;
END $$
CREATE PROCEDURE `del_from_post` (IN post_id INT) 
    BEGIN 
  		#SET @enabled = TRUE;
  		#SET @post_id1 = post_id;

  		#call debug_msg(@enabled, "my first debug message");
  		#call debug_msg(@enabled, post_id);
  		#call debug_msg(@enabled, @post_id1);
  		#SET @cnt = (select count(1) from `blog_db`.`picture` p where p.post_id = post_id); 
  		#call debug_msg(@enabled, @cnt);
	    START TRANSACTION;
	        UPDATE `blog_db`.`picture` p SET `deleted` = '1' WHERE p.post_id = post_id;
	        UPDATE `blog_db`.`user_viewed_post` uvp SET `deleted` = '1' WHERE uvp.post_id = post_id;
	        UPDATE `blog_db`.`like` l SET `deleted` = '1' WHERE l.post_id = post_id;
	        UPDATE `blog_db`.`comment` c SET `deleted` = '1' WHERE c.post_id = post_id;
	        UPDATE `blog_db`.`post` p SET `deleted` = '1' WHERE p.id = post_id;
       COMMIT;
    END $$

CALL del_from_post(2);

CALL del_from_picture(1);

CALL del_from_picture(2);

CALL del_from_comment(7);


select * 
from blog_db.picture
;

select count(1) from `blog_db`.`picture` where post_id = 1
;


SET @post_id = '1';    
	        UPDATE `blog_db`.`picture` SET `deleted` = '1' WHERE `post_id` = @post_id;
	        UPDATE `blog_db`.`user_viewed_post` SET `deleted` = '1' WHERE `post_id` = @post_id;
	        UPDATE `blog_db`.`like` SET `deleted` = '1' WHERE `post_id` = @post_id;
	        UPDATE `blog_db`.`comment` SET `deleted` = '1' WHERE `post_id` = @post_id;
	        UPDATE `blog_db`.`post` SET `deleted` = '1' WHERE `id` = @post_id;
    

DELIMITER $$

DROP PROCEDURE IF EXISTS `debug_msg`;
DROP PROCEDURE IF EXISTS `test_procedure`;

DELIMITER $$
CREATE PROCEDURE debug_msg(enabled INTEGER, msg VARCHAR(255))
BEGIN
  IF enabled THEN BEGIN
    select concat("** ", msg) AS '** DEBUG:';
  END; END IF;
END $$

DELIMITER $$
CREATE PROCEDURE test_procedure(arg1 INTEGER, arg2 INTEGER)
BEGIN
  SET @enabled = TRUE;

  call debug_msg(@enabled, "my first debug message");
  call debug_msg(@enabled, (select concat_ws('',"arg1:", arg1)));
  call debug_msg(TRUE, "This message always shows up");
  call debug_msg(FALSE, "This message will never show up");
END $$

DELIMITER ;

CALL test_procedure(1,2);



INSERT INTO post(post, dt, title, author_user_id, last_edit_dt, lead1, visible, referenced_post_id, deleted) 
VALUES 
	('text12', '2018-11-02', 'Супер название статьи 12', 5, '2018-11-02', 'Вводный текст к статье 12', TRUE, 0, FALSE)
;

INSERT INTO `blog_db`.`user` (name, `password`, blocked)
VALUES 
	('superuser', '234234', FALSE)
;

SET FOREIGN_KEY_CHECKS=1;
INSERT INTO `blog_db`.`picture` (post_id, file_name, caption, deleted)
VALUES 
	(202, '2.txt', 'caption', FALSE)
;

show create table `blog_db`.`picture`;

INSERT INTO comment(id, post_id, comment_text, user_id, deleted) 
VALUES 
	(14, 1, 'А мне - нравится!', 2, FALSE)
;

INSERT INTO `like`(post_id, user_id, deleted) 
VALUES 
	(7, 6, FALSE)
;

INSERT INTO blog_db.user_viewed_post(post_id, user_id, views_no, last_view_dt)
VALUES (3, 3, 1, CURDATE())
ON DUPLICATE KEY UPDATE views_no = views_no + 1;

INSERT INTO blog_db.user_viewed_post(post_id, user_id, views_no, last_view_dt)
VALUES (1, 7, 1, '2000-01-01')
;

ON DUPLICATE KEY UPDATE views_no = views_no + 1;

