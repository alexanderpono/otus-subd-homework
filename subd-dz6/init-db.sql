-- MySQL Script generated by MySQL Workbench
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema blog_db
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `blog_db` ;

-- -----------------------------------------------------
-- Schema blog_db
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `blog_db` DEFAULT CHARACTER SET utf8 collate utf8_general_ci;
USE `blog_db` ;

-- -----------------------------------------------------
-- Table `blog_db`.`user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `blog_db`.`user` (
  `id` SMALLINT NOT NULL AUTO_INCREMENT COMMENT 'Количество пользователей - вряд ли будет больше 65536. заменить INT -> SMALLINT\nВсе значения уникальные',
  `name` VARCHAR(128) NOT NULL COMMENT 'Делаю NOT NULL. Поле должно быть заполнено при вставке\nСтавлю UNIQUE - пользователи на форуме должны быть с разными именами\nКардинальность = количество записей в таблице',
  `password` BINARY(16) NOT NULL COMMENT 'пароль \nNOT NULL - задать значение при вставки записи\nкардинальность - близка к количеству записей в таблице',
  `blocked` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'признак блокировки пользователя\nNOT NULL - задать значение при вставке, по умолчанию 0\nкардинальность = 2',
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `id_name_UNIQUE` ON `blog_db`.`user` (`id` ASC, `name` ASC);


-- -----------------------------------------------------
-- Table `blog_db`.`post`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `blog_db`.`post` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'Количество постов в блоге может быть большое. Оставляем INT.\nВсе значения уникальные',
  `post` TEXT NOT NULL COMMENT 'Размер статьи - не более 65535 символов. Ставлю NOT NULL со значением по умолчанию\nКардинальность - сравнима с количеством записей в таблице',
  `dt` DATETIME NOT NULL DEFAULT '2000-01-01' COMMENT 'Дата и время статьи - оставляем DATETIME. Ставлю NOT NULL, задаю default value\nКардинальность - сравнима с количеством записей в таблице',
  `title` VARCHAR(255) NOT NULL DEFAULT '-' COMMENT 'Название статьи - не более 255 символов. Поставил NOT NULL DEFAULT=\'-\'\nКардинальность - сравнима с количеством записей в таблице',
  `author_user_id` SMALLINT NOT NULL COMMENT 'Количество пользователей - вряд ли будет больше 65536. заменить INT -> SMALLINT\nКардинальность растет с увеличением активных авторов',
  `last_edit_dt` DATETIME NOT NULL COMMENT 'Оставить DATETIME. ставлю NOT NULL. Поле должно быть задано при вставке записи\nКардинальность - сравнима с количеством записей в таблице',
  `lead1` VARCHAR(255) NOT NULL DEFAULT '-' COMMENT 'Поле \"анонс статьи\", макс. длина 255\nКардинальность - сравнима с количеством записей в таблице',
  `visible` TINYINT(1) NOT NULL COMMENT 'статус статьи (BOOL)\nNOT NULL - задать значение поля при вставке\nкардинальность = 2',
  `referenced_post_id` INT NOT NULL DEFAULT 0 COMMENT 'ID статьи, которую репостит данная статья\nодна статья может репостить только одну статью\nNOT NULL - DEFAULT=0 (если статья не репостит ничего, то = 0)\nкардинальность - O (количество записей в post)',
  `deleted` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'признак удаления записи (BOOL)\nNOT NULL, DEFAULT=0\nкардинальность = 2',
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `id_UNIQUE` ON `blog_db`.`post` (`id` ASC);

-- -----------------------------------------------------
-- Table `blog_db`.`picture`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `blog_db`.`picture` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'Количество картинок в блоге может быть большое. Оставляем INT\nВсе значения уникальные\n',
  `post_id` INT NOT NULL COMMENT 'Кардинальность - увеличивается по мере публикации новых статей',
  `file_name` VARCHAR(45) NOT NULL DEFAULT '-' COMMENT 'Избавляюсь от NULL. Ставлю default = \'-\'\nКардинальность - увеличивается по мере публикации статей',
  `caption` VARCHAR(64) NOT NULL DEFAULT '-' COMMENT 'Избавляюсь от NULL. Ставлю default = \'-\'\nКардинальность - увеличивается по мере публикации статей',
  `deleted` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'признак удаления записи (BOOL)\nNOT NULL, DEFAULT=0\nкардинальность = 2',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_picture_1`
    FOREIGN KEY (`post_id`)
    REFERENCES `blog_db`.`post` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `id_UNIQUE` ON `blog_db`.`picture` (`id` ASC);


-- -----------------------------------------------------
-- Table `blog_db`.`comment`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `blog_db`.`comment` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'Количество комментариев в блоге может быть большое. Оставляем INT\nВсе значения уникальные',
  `post_id` INT NOT NULL COMMENT 'Кардинальность - увеличивается по мере публикации статей\nКардинальность близка к количеству постов',
  `comment_text` VARCHAR(128) NOT NULL DEFAULT '-' COMMENT 'Избавляюсь от NULL. Ставлю default = \'-\'\nКардинальность близка к количеству записей в таблице',
  `user_id` SMALLINT NOT NULL COMMENT 'Количество пользователей - вряд ли будет больше 65536. заменить INT -> SMALLINT\nКардинальность близка к количеству пользователей',
  `deleted` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'признак удаления записи (BOOL)\nNOT NULL, DEFAULT=0\nкардинальность = 2',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_comment_post_id`
    FOREIGN KEY (`post_id`)
    REFERENCES `blog_db`.`post` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_comment_user_id`
    FOREIGN KEY (`user_id`)
    REFERENCES `blog_db`.`user` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `id_UNIQUE` ON `blog_db`.`comment` (`id` ASC);


-- -----------------------------------------------------
-- Table `blog_db`.`like`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `blog_db`.`like` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'Количество лайков в блоге может быть большое. Оставляем INT\nВсе значения уникальные',
  `post_id` INT NOT NULL COMMENT 'Кардинальность - увеличивается по мере публикации статей',
  `user_id` SMALLINT NOT NULL COMMENT 'Количество пользователей - вряд ли будет больше 65536. заменить INT -> SMALLINT\nКардинальность растет с увеличением активных читателей',
  `deleted` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'признак удаления записи (BOOL)\nNOT NULL, DEFAULT=0\nкардинальность = 2',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_like_post_id`
    FOREIGN KEY (`post_id`)
    REFERENCES `blog_db`.`post` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_like_user_id`
    FOREIGN KEY (`user_id`)
    REFERENCES `blog_db`.`user` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `id_UNIQUE` ON `blog_db`.`like` (`id` ASC);


-- -----------------------------------------------------
-- Table `blog_db`.`user_viewed_post`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `blog_db`.`user_viewed_post` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'Количество просмотров на весь блог может быть большое. Оставляем INT\nВсе значения уникальные',
  `post_id` INT NOT NULL COMMENT 'Кардинальность - O (количество статей*количество пользователей)',
  `user_id` SMALLINT NOT NULL COMMENT 'Количество пользователей - вряд ли будет больше 65536. заменить INT -> SMALLINT\nКардинальность растет с у величением количества пользователей',
  `views_no` SMALLINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Избавляюсь от NULL. Ставлю default = \'0\'\nКардинальность ограничена размером данных <=255\nУстанавливаю флаг unsigned',
  `last_view_dt` DATETIME NOT NULL COMMENT 'Избавляюсь от NULL. Поле должо быть задано при вставке записи\nКардинальность близка к количеству записей в таблице',
  `deleted` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'признак удаления записи (BOOL)\nNOT NULL, DEFAULT=0\nкардинальность = 2',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_user_viewed_post_post_id`
    FOREIGN KEY (`post_id`)
    REFERENCES `blog_db`.`post` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_viewed_post_user_id`
    FOREIGN KEY (`user_id`)
    REFERENCES `blog_db`.`user` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `id_UNIQUE` ON `blog_db`.`user_viewed_post` (`id` ASC);
CREATE UNIQUE INDEX `post_id_user_id_UNIQUE` ON `blog_db`.`user_viewed_post` (`post_id`, `user_id`);

ALTER TABLE `blog_db`.`post` ADD CONSTRAINT `fk_post_user_id`
    FOREIGN KEY (`author_user_id`)
    REFERENCES `blog_db`.`user` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

   


USE `blog_db`;

DELIMITER $$
USE `blog_db`$$
CREATE DEFINER = CURRENT_USER TRIGGER `blog_db`.`user_viewed_post_BEFORE_INSERT` BEFORE INSERT ON `user_viewed_post` FOR EACH ROW
BEGIN
	SET @postDate = (SELECT `dt` FROM `blog_db`.`post` WHERE `blog_db`.`post`.`id` = NEW.`post_id`);
    IF (@postDate > NEW.`last_view_dt`) THEN 
		SIGNAL SQLSTATE '12345'
			SET MESSAGE_TEXT = 'check constraint on user_viewed_post.last_view_dt failed';    
    END IF;
END $$

CREATE PROCEDURE `del_from_post` (IN post_id INT) 
    BEGIN 
	    START TRANSACTION;
	        UPDATE `blog_db`.`picture` p SET `deleted` = '1' WHERE p.post_id = post_id;
	        UPDATE `blog_db`.`user_viewed_post` uvp SET `deleted` = '1' WHERE uvp.post_id = post_id;
	        UPDATE `blog_db`.`like` l SET `deleted` = '1' WHERE l.post_id = post_id;
	        UPDATE `blog_db`.`comment` c SET `deleted` = '1' WHERE c.post_id = post_id;
	        UPDATE `blog_db`.`post` p SET `deleted` = '1' WHERE p.id = post_id;
       COMMIT;
    END $$


CREATE PROCEDURE `del_from_picture` (IN picture_id INT) 
    BEGIN 
        UPDATE `blog_db`.`picture` p SET `deleted` = '1' WHERE p.id = picture_id;
    END $$

CREATE PROCEDURE `del_from_comment` (IN comment_id INT) 
    BEGIN 
        UPDATE `blog_db`.comment c SET `deleted` = '1' WHERE c.id = comment_id;
    END $$

DELIMITER ;


INSERT INTO user(id, name, password, blocked) 
VALUES 
	(1, 'user1', 123123, false),  
	(2, 'user2', 123123, false),  
	(3, 'user3', 123123, false),
	(4, 'user4', 123123, false),
	(5, 'user5', 123123, false),
	(6, 'user6', 123123, false)
;

INSERT INTO post(id, post, dt, title, author_user_id, last_edit_dt, lead1, visible, referenced_post_id, deleted) 
VALUES 
	(1, 'text1', '2018-11-01', 'Супер название статьи 1', 1, '2018-11-01', 'Вводный текст к статье 1', TRUE, 0, FALSE),
	(2, 'text2', '2018-11-01', 'Супер название статьи 2', 2, '2018-11-01', 'Вводный текст к статье 2', TRUE, 0, FALSE),
	(3, 'text3', '2018-11-01', 'Супер название статьи 3', 2, '2018-11-01', 'Вводный текст к статье 3', TRUE, 0, FALSE),
	(4, 'text4', '2018-11-02', 'Супер название статьи 4', 1, '2018-11-02', 'Вводный текст к статье 4', TRUE, 0, FALSE),
	(5, 'text5', '2018-11-02', 'Супер название статьи 5', 1, '2018-11-02', 'Вводный текст к статье 5', TRUE, 0, TRUE),
	(6, 'text6', '2018-11-01', 'Супер название статьи 6', 2, '2018-11-01', 'Вводный текст к статье 6', TRUE, 0, FALSE),
	(7, 'text7', '2018-11-02', 'Супер название статьи 7', 3, '2018-11-02', 'Вводный текст к статье 7', TRUE, 0, FALSE),
	(8, 'text8', '2018-11-01', 'Супер название статьи 8', 1, '2018-11-01', 'Вводный текст к статье 8', TRUE, 0, FALSE),
	(9, 'text9', '2018-11-01', 'Супер название статьи 9', 2, '2018-11-01', 'Вводный текст к статье 9', TRUE, 0, FALSE),
	(10, 'text10', '2018-11-01', 'Супер название статьи 10', 3, '2018-11-01', 'Вводный текст к статье 10', TRUE, 0, FALSE),
	(11, 'text11', '2018-11-02', 'Супер название статьи 11', 4, '2018-11-02', 'Вводный текст к статье 11', TRUE, 0, FALSE)
;

INSERT INTO picture(id, post_id, file_name, caption, deleted) 
VALUES 
	(1, 1, '1.jpg', 'Золотая осень', FALSE),
	(2, 2, '12.jpg', 'Котик', FALSE)
;

INSERT INTO comment(id, post_id, comment_text, user_id, deleted) 
VALUES 
	(1, 1, 'Красивое фото!', 2, FALSE),
	(2, 1, 'А мне не нравится', 3, FALSE),
	(3, 1, 'А мне - нравится!', 2, FALSE)
;

INSERT INTO comment(post_id, comment_text, user_id, deleted)
SELECT post_id, comment_text, user_id, deleted 
FROM comment
WHERE post_id='1';

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

UPDATE comment
SET deleted=TRUE
WHERE id IN(11,12);

INSERT INTO `like`(id, post_id, user_id, deleted) 
VALUES 
	(1, 1, 2, FALSE),
	(2, 2, 3, FALSE),
	(3, 2, 2, FALSE),
	(4, 1, 1, FALSE),
	(5, 4, 1, FALSE),
	(6, 1, 3, FALSE),
	(7, 2, 4, FALSE),
	(8, 1, 5, FALSE),
	(9, 4, 5, FALSE),
	(10, 1, 6, FALSE),
	(11, 5, 5, FALSE),
	(12, 6, 5, FALSE),
	(13, 7, 6, FALSE)
;

INSERT INTO user_viewed_post(id, post_id, user_id, views_no, last_view_dt, deleted) 
VALUES 
	(1, 1, 1,	 5, '2018-11-10', FALSE),
	(2, 1, 2, 3, '2018-11-11', FALSE),
	(3, 1, 3, 2, '2018-11-10', FALSE),
	(4, 2, 1, 2, '2018-11-10', FALSE),
	(5, 2, 2, 4, '2018-11-11', FALSE),
	(6, 2, 3, 10, '2018-11-10', FALSE),
	(7, 3, 1, 2, '2018-11-10', FALSE),
	(8, 3, 2, 4, '2018-11-11', FALSE),
	(9, 3, 3, 10, '2018-11-10', FALSE),
	(10, 4, 1, 2, '2018-11-10', FALSE),
	(11, 4, 2, 4, '2018-11-11', FALSE),
	(12, 5, 6, 5, '2018-11-10', FALSE),
	(13, 5, 5, 8, '2018-11-10', FALSE),
	(14, 6, 4, 7, '2018-11-10', FALSE),
	(15, 7, 3, 2, '2018-11-10', FALSE),
	(16, 7, 2, 5, '2018-11-10', FALSE)
;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;




