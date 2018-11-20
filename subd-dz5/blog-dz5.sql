-- MySQL Script generated by MySQL Workbench
-- Вс 28 окт 2018 18:02:48
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
CREATE SCHEMA IF NOT EXISTS `blog_db` DEFAULT CHARACTER SET utf8 ;
USE `blog_db` ;

-- -----------------------------------------------------
-- Table `blog_db`.`user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `blog_db`.`user` (
  `id` SMALLINT NOT NULL AUTO_INCREMENT COMMENT 'Количество пользователей - вряд ли будет больше 65536. заменить INT -> SMALLINT\nВсе значения уникальные',
  `name` VARCHAR(128) NOT NULL COMMENT 'Делаю NOT NULL. Поле должно быть заполнено при вставке\nСтавлю UNIQUE - пользователи на форуме должны быть с разными именами\nКардинальность = количество записей в таблице',
  `password` VARCHAR(32) NOT NULL COMMENT 'пароль \nNOT NULL - задать значение при вставки записи\nкардинальность - близка к количеству записей в таблице',
  `blocked` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'признак блокировки пользователя\nNOT NULL - задать значение при вставке, по умолчанию 0\nкардинальность = 2',
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `name_UNIQUE` ON `blog_db`.`user` (`name` ASC);

CREATE UNIQUE INDEX `id_UNIQUE` ON `blog_db`.`user` (`id` ASC);


-- -----------------------------------------------------
-- Table `blog_db`.`post`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `blog_db`.`post` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'Количество постов в блоге может быть большое. Оставляем INT.\nВсе значения уникальные',
  `post` TEXT NOT NULL DEFAULT '-' COMMENT 'Размер статьи - не более 65535 символов. Ставлю NOT NULL со значением по умолчанию\nКардинальность - сравнима с количеством записей в таблице',
  `dt` DATETIME NOT NULL DEFAULT 2000/01/01 COMMENT 'Дата и время статьи - оставляем DATETIME. Ставлю NOT NULL, задаю default value\nКардинальность - сравнима с количеством записей в таблице',
  `title` VARCHAR(255) NOT NULL DEFAULT '-' COMMENT 'Название статьи - не более 255 символов. Поставил NOT NULL DEFAULT=\'-\'\nКардинальность - сравнима с количеством записей в таблице',
  `author_user_id` SMALLINT NOT NULL COMMENT 'Количество пользователей - вряд ли будет больше 65536. заменить INT -> SMALLINT\nКардинальность растет с увеличением активных авторов',
  `last_edit_dt` DATETIME NOT NULL COMMENT 'Оставить DATETIME. ставлю NOT NULL. Поле должно быть задано при вставке записи\nКардинальность - сравнима с количеством записей в таблице',
  `lead` VARCHAR(255) NOT NULL DEFAULT '-' COMMENT 'Поле \"анонс статьи\", макс. длина 255\nКардинальность - сравнима с количеством записей в таблице',
  `visible` TINYINT(1) NOT NULL COMMENT 'статус статьи (BOOL)\nNOT NULL - задать значение поля при вставке\nкардинальность = 2',
  `referenced_post_id` INT NOT NULL DEFAULT 0 COMMENT 'ID статьи, которую репостит данная статья\nодна статья может репостить только одну статью\nNOT NULL - DEFAULT=0 (если статья не репостит ничего, то = 0)\nкардинальность - O (количество записей в post)',
  `deleted` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'признак удаления записи (BOOL)\nNOT NULL, DEFAULT=0\nкардинальность = 2',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_post_user_id`
    FOREIGN KEY (`author_user_id`)
    REFERENCES `blog_db`.`user` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_post_referenced_post_id`
    FOREIGN KEY (`id`)
    REFERENCES `blog_db`.`post` (`referenced_post_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_post_user_id_idx` ON `blog_db`.`post` (`author_user_id` ASC)  COMMENT 'индекс на foreign key - для связки таблиц в запросах';

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

CREATE INDEX `fk_picture_1_idx` ON `blog_db`.`picture` (`post_id` ASC)  COMMENT 'индекс на foreign key - для связки таблиц в запросах';

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

CREATE INDEX `fk_comment_post_id_idx` ON `blog_db`.`comment` (`post_id` ASC)  COMMENT 'индекс на foreign key - для связки таблиц в запросах';

CREATE INDEX `fk_comment_user_id_idx` ON `blog_db`.`comment` (`user_id` ASC)  COMMENT 'индекс на foreign key - для связки таблиц в запросах';

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

CREATE INDEX `fk_like_post_id_idx` ON `blog_db`.`like` (`post_id` ASC)  COMMENT 'индекс на foreign key - для связки таблиц в запросах';

CREATE INDEX `fk_like_user_id_idx` ON `blog_db`.`like` (`user_id` ASC)  COMMENT 'индекс на foreign key - для связки таблиц в запросах';

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

CREATE INDEX `fk_user_viewed_post_post_id_idx` ON `blog_db`.`user_viewed_post` (`post_id` ASC)  COMMENT 'индекс на foreign key - для связки таблиц в запросах';

CREATE INDEX `fk_user_viewed_post_user_id_idx` ON `blog_db`.`user_viewed_post` (`user_id` ASC)  COMMENT 'индекс на foreign key - для связки таблиц в запросах';

CREATE UNIQUE INDEX `id_UNIQUE` ON `blog_db`.`user_viewed_post` (`id` ASC);

USE `blog_db`;

DELIMITER $$
USE `blog_db`$$
CREATE DEFINER = CURRENT_USER TRIGGER `mydb`.`user_viewed_post_BEFORE_INSERT` BEFORE INSERT ON `user_viewed_post` FOR EACH ROW
BEGIN
	SET @postDate = (SELECT `dt` FROM `mydb`.`post` WHERE `mydb`.`post`.`id` = NEW.`post_id`);
    IF (@postDate > NEW.`last_view_dt`) THEN 
		SIGNAL SQLSTATE '12345'
			SET MESSAGE_TEXT = 'check constraint on user_viewed_post.last_view_dt failed';    
    END IF;
END$$


DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;