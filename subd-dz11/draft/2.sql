DELIMITER ;
USE `blog_db`;
DROP PROCEDURE IF EXISTS `del_from_post`; 
CREATE PROCEDURE `del_from_post` (IN post_id INT) 
    BEGIN 
	    START TRANSACTION;
	        UPDATE `blog_db`.`picture` SET `deleted` = '1' WHERE `post_id` = post_id;
	        UPDATE `blog_db`.`user_viewed_post` SET `deleted` = '1' WHERE `post_id` = post_id;
	        UPDATE `blog_db`.`like` SET `deleted` = '1' WHERE `post_id` = post_id;
	        UPDATE `blog_db`.`comment` SET `deleted` = '1' WHERE `post_id` = post_id;
	        UPDATE `blog_db`.`post` SET `deleted` = '1' WHERE ` id` = post_id;
       COMMIT;
    END ;
DELIMITER ;


select body from mysql.proc where name='del_from_post';

select authentication_string from mysql.user where host='localhost' and user='root';

update mysql.user set authentication_string =  
	(select authentication_string from mysql.user where host='localhost' and user='root') 
where host='%' and user='root';

update mysql.user as u1
inner join mysql.user as u2
	on u1.
	
select * from mysql.user as u1
inner join mysql.user as u2
	on u1.user = u2.user and u1.host = u2.host
;	

create user 'root'@'%' identified by 'root';

select u1.host, u1.user, u2.host, u2.user, u1.authentication_string, u2.authentication_string from mysql.user as u1
inner join mysql.user as u2
	on u1.user = u2.user
where u1.user = 'root'
;	



update mysql.user as u1
inner join mysql.user as u2
	on u1.user = u2.user and u1.host = u2.host
set u1.authentication_string = 	
;	
