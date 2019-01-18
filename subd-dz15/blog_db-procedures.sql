DROP TRIGGER IF EXISTS blog_db.user_viewed_post_BEFORE_INSERT;
DROP PROCEDURE IF EXISTS blog_db.del_from_post;
DROP PROCEDURE IF EXISTS blog_db.del_from_picture;
DROP PROCEDURE IF EXISTS blog_db.del_from_comment;
DROP PROCEDURE IF EXISTS blog_db.user_viewed_post;
DROP PROCEDURE IF EXISTS blog_db.debug_msg;
DROP PROCEDURE IF EXISTS blog_db.init_posts_precalculated;
DROP PROCEDURE IF EXISTS blog_db.user_likes_post;
DROP PROCEDURE IF EXISTS blog_db.user_unlikes_post;



DELIMITER $$
USE `blog_db`$$


CREATE DEFINER = CURRENT_USER TRIGGER blog_db.user_viewed_post_BEFORE_INSERT BEFORE INSERT ON user_viewed_post FOR EACH ROW
BEGIN
	SET @postDate = (SELECT `dt` FROM blog_db.post WHERE blog_db.post.id = NEW.post_id);
    IF (@postDate > NEW.last_view_dt) THEN 
		SIGNAL SQLSTATE '12345'
			SET MESSAGE_TEXT = 'check constraint on user_viewed_post.last_view_dt failed';    
    END IF;
END $$


CREATE PROCEDURE blog_db.del_from_post (IN post_id INT) 
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
  	BEGIN
		ROLLBACK;
  	END;
  
    START TRANSACTION;
        UPDATE blog_db.picture SET deleted = '1' WHERE `post_id` = post_id;
        UPDATE blog_db.user_viewed_post SET deleted = '1' WHERE `post_id` = post_id;
        UPDATE blog_db.`like` SET deleted = '1' WHERE `post_id` = post_id;
        UPDATE blog_db.comment SET deleted = '1' WHERE `post_id` = post_id;
        UPDATE blog_db.post SET deleted = '1' WHERE id = post_id;
   COMMIT;
END $$


CREATE PROCEDURE blog_db.del_from_picture (IN picture_id INT) 
BEGIN 
    UPDATE blog_db.picture SET deleted = '1' WHERE id = picture_id;
END $$


CREATE PROCEDURE blog_db.del_from_comment (IN comment_id INT) 
BEGIN 
    UPDATE blog_db.picture SET deleted = '1' WHERE id = comment_id;
END $$


CREATE PROCEDURE blog_db.user_viewed_post (IN user_id INT, IN post_id INT) 
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
  	BEGIN
		ROLLBACK;
  	END;

	START TRANSACTION;
	    INSERT INTO blog_db.user_viewed_post(`post_id`, `user_id`, views_no, last_view_dt)
		VALUES (post_id, user_id, 1, CURDATE())
		ON DUPLICATE KEY UPDATE 
			views_no = views_no + 1,
			last_view_dt = CURDATE()
		;
	
		UPDATE blog_db.post p
		SET p.views_count = p.views_count + 1
		WHERE p.id = post_id
		;
	COMMIT;
	
END $$


CREATE PROCEDURE blog_db.init_posts_precalculated () 
BEGIN 
	DECLARE DONE  INT DEFAULT 0;
	DECLARE id INT;
	DECLARE likes_count INT;
	DECLARE views_count INT;
	DECLARE CUR CURSOR FOR 
		select 
			p.id, 
	 		(select count(1) from blog_db.`like` l where l.post_id=p.id) as likes_count,
			(SELECT COALESCE(SUM(uvp.views_no), 0) FROM blog_db.user_viewed_post as uvp WHERE uvp.post_id = p.id) as views_count
		from blog_db.post p
	;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET DONE = 1;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
  	BEGIN
		ROLLBACK;
  	END;
  

    START TRANSACTION;

	OPEN CUR;
	REPEAT
		FETCH CUR INTO id, likes_count, views_count;
		IF NOT DONE THEN
 			UPDATE blog_db.post p
 			SET p.views_count = views_count, p.likes_count = likes_count
 			WHERE p.id = id
 			;
		END IF;
	UNTIL DONE END REPEAT;
	CLOSE CUR;

	COMMIT;

END $$


CREATE PROCEDURE blog_db.user_likes_post (IN user_id INT, IN post_id INT) 
BEGIN
	DECLARE already_likes INT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
  	BEGIN
		ROLLBACK;
  	END;
  
	
	select 1  
	where exists(
		select id from blog_db.`like` l where l.post_id = post_id AND l.user_id=user_id
	) 
	into already_likes
	;

	if already_likes is null then
		START TRANSACTION;
			insert into blog_db.`like`(`post_id`, `user_id`)
			values(post_id, user_id)
			;
		
			UPDATE blog_db.post p
			SET p.likes_count = p.likes_count + 1
			WHERE p.id = post_id
			;
		COMMIT;
		
	end if;

END $$


CREATE PROCEDURE blog_db.user_unlikes_post (IN user_id1 INT, IN post_id1 INT) 
BEGIN
	DECLARE already_likes INT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
  	BEGIN
		ROLLBACK;
  	END;
  
	
	select 1  
	where exists(
		select id from blog_db.`like` l where l.post_id = post_id1 AND l.user_id=user_id1
	) 
	into already_likes;

	if already_likes is not null then
		START TRANSACTION;
			delete from blog_db.`like`
			where `post_id` = post_id1 and `user_id`=user_id1
			;
		
			UPDATE blog_db.post p
			SET p.likes_count = p.likes_count - 1
			WHERE p.id = post_id1
			;
		COMMIT;
		
	end if;

END $$




DELIMITER ;


call blog_db.init_posts_precalculated();
	
