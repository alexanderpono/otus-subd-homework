USE `blog_db`;
DROP PROCEDURE IF EXISTS `del_from_post`; 
DROP PROCEDURE IF EXISTS `del_from_picture`; 
DROP PROCEDURE IF EXISTS `del_from_comment`; 
DELIMITER // 
CREATE PROCEDURE `del_from_post` (IN post_id INT) 
BEGIN
    START TRANSACTION;
        UPDATE `blog_db`.`picture` SET `deleted` = '1' WHERE `post_id` = post_id;
        UPDATE `blog_db`.`user_viewed_post` SET `deleted` = '1' WHERE `post_id` = post_id;
        UPDATE `blog_db`.`like` SET `deleted` = '1' WHERE `post_id` = post_id;
        UPDATE `blog_db`.`comment` SET `deleted` = '1' WHERE `post_id` = post_id;
        UPDATE `blog_db`.`post` SET `deleted` = '1' WHERE ` id` = post_id;
   COMMIT;
END //



CREATE PROCEDURE `del_from_picture` (IN picture_id INT) 
    BEGIN 
        UPDATE `blog_db`.`picture` SET `deleted` = '1' WHERE `id` = picture_id;
    END //

CREATE PROCEDURE `del_from_comment` (IN comment_id INT) 
    BEGIN 
        UPDATE `blog_db`.`picture` SET `deleted` = '1' WHERE `id` = comment_id;
    END //

DELIMITER ;
