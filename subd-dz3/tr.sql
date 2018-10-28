CREATE DEFINER = CURRENT_USER TRIGGER `mydb`.`user_viewed_post_BEFORE_INSERT` BEFORE INSERT ON `user_viewed_post` FOR EACH ROW
BEGIN
	SET @postDate = (SELECT `dt` FROM `mydb`.`post` WHERE `mydb`.`post`.`id` = NEW.`post_id`);
    IF (@postDate > NEW.`last_view_dt`) THEN 
		SIGNAL SQLSTATE '12345'
			SET MESSAGE_TEXT := 'check constraint on user_viewed_post.last_view_dt failed';    
    END IF;
END
