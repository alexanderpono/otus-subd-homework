-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema booking
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `booking` ;

-- -----------------------------------------------------
-- Schema booking
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `booking` DEFAULT CHARACTER SET utf8 ;
USE `booking` ;

-- -----------------------------------------------------
-- Table `booking`.`city`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `booking`.`city` (
  `id` INT NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `id_UNIQUE` ON `booking`.`city` (`id` ASC);


-- -----------------------------------------------------
-- Table `booking`.`hotel`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `booking`.`hotel` (
  `id` INT NOT NULL,
  `address` VARCHAR(128) NOT NULL,
  `city_id` INT NOT NULL,
  `name` VARCHAR(45) NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_hotel_city_id`
    FOREIGN KEY (`city_id`)
    REFERENCES `booking`.`city` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `id_UNIQUE` ON `booking`.`hotel` (`id` ASC);

CREATE INDEX `fk_hotel_city_id_idx` ON `booking`.`hotel` (`city_id` ASC);


-- -----------------------------------------------------
-- Table `booking`.`room_type`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `booking`.`room_type` (
  `id` INT NOT NULL,
  `caption` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `id_UNIQUE` ON `booking`.`room_type` (`id` ASC);


-- -----------------------------------------------------
-- Table `booking`.`room`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `booking`.`room` (
  `id` INT NOT NULL,
  `caption` VARCHAR(45) NOT NULL,
  `description` VARCHAR(128) NOT NULL,
  `adults_count` TINYINT(2) NOT NULL,
  `room_type_id` INT NOT NULL,
  `hotel_id` INT NOT NULL,
  `square` DECIMAL(3,1) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_room_room_type_id`
    FOREIGN KEY (`room_type_id`)
    REFERENCES `booking`.`room_type` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_room_hotel_id`
    FOREIGN KEY (`hotel_id`)
    REFERENCES `booking`.`hotel` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `id_UNIQUE` ON `booking`.`room` (`id` ASC);

CREATE INDEX `fk_room_room_type_id_idx` ON `booking`.`room` (`room_type_id` ASC);

CREATE INDEX `fk_room_hotel_id_idx` ON `booking`.`room` (`hotel_id` ASC);


-- -----------------------------------------------------
-- Table `booking`.`room_attribute`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `booking`.`room_attribute` (
  `id` INT NOT NULL,
  `caption` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `id_UNIQUE` ON `booking`.`room_attribute` (`id` ASC);


-- -----------------------------------------------------
-- Table `booking`.`room_has_attribute`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `booking`.`room_has_attribute` (
  `id` INT NOT NULL,
  `room_id` INT NOT NULL,
  `room_attribute_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_room_has_attribute_room_attr_id`
    FOREIGN KEY (`room_attribute_id`)
    REFERENCES `booking`.`room_attribute` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_room_has_attribute_room_id`
    FOREIGN KEY (`room_id`)
    REFERENCES `booking`.`room` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `id_UNIQUE` ON `booking`.`room_has_attribute` (`id` ASC);

CREATE INDEX `fk_room_has_attribute_room_attr_id_idx` ON `booking`.`room_has_attribute` (`room_attribute_id` ASC);

CREATE INDEX `fk_room_has_attribute_room_id_idx` ON `booking`.`room_has_attribute` (`room_id` ASC);


-- -----------------------------------------------------
-- Table `booking`.`time_template`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `booking`.`time_template` (
  `id` INT NOT NULL,
  `start_month` TINYINT(2) NOT NULL,
  `start_day` TINYINT(2) NOT NULL,
  `end_month` TINYINT(2) NOT NULL,
  `end_day` TINYINT(2) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `id_UNIQUE` ON `booking`.`time_template` (`id` ASC);


-- -----------------------------------------------------
-- Table `booking`.`price`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `booking`.`price` (
  `id` INT NOT NULL,
  `room_id` INT NOT NULL,
  `start_month` TINYINT(2) NOT NULL DEFAULT 0,
  `start_day` TINYINT(2) NOT NULL DEFAULT 0,
  `end_month` TINYINT(2) NOT NULL DEFAULT 0,
  `end_day` TINYINT(2) NOT NULL DEFAULT 0,
  `base_price` DECIMAL(5,2) NOT NULL,
  `add_child_price` DECIMAL(5,2) NOT NULL DEFAULT 0,
  `time_template_id` INT NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_price_room_id`
    FOREIGN KEY (`room_id`)
    REFERENCES `booking`.`room` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_price_time_template_id`
    FOREIGN KEY (`time_template_id`)
    REFERENCES `booking`.`time_template` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `id_UNIQUE` ON `booking`.`price` (`id` ASC);

CREATE INDEX `fk_price_room_id_idx` ON `booking`.`price` (`room_id` ASC);

CREATE INDEX `fk_price_time_template_id_idx` ON `booking`.`price` (`time_template_id` ASC);


-- -----------------------------------------------------
-- Table `booking`.`photo`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `booking`.`photo` (
  `id` INT NOT NULL,
  `file_name` VARCHAR(45) NOT NULL,
  `room_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_photo_room_id`
    FOREIGN KEY (`room_id`)
    REFERENCES `booking`.`room` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `id_UNIQUE` ON `booking`.`photo` (`id` ASC);

CREATE INDEX `fk_photo_room_id_idx` ON `booking`.`photo` (`room_id` ASC);


-- -----------------------------------------------------
-- Table `booking`.`client`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `booking`.`client` (
  `id` INT NOT NULL,
  `first_name` VARCHAR(45) NOT NULL,
  `email` VARCHAR(45) NOT NULL,
  `phone_number` VARCHAR(20) NOT NULL DEFAULT '',
  `password` BINARY(16) NOT NULL,
  `email_confirmed` TINYINT(1) NOT NULL DEFAULT 0,
  `last_name` VARCHAR(45) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `id_UNIQUE` ON `booking`.`client` (`id` ASC);


-- -----------------------------------------------------
-- Table `booking`.`reservation`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `booking`.`reservation` (
  `id` INT NOT NULL,
  `room_id` INT NOT NULL,
  `start_date` DATE NOT NULL,
  `end_date` DATE NOT NULL,
  `adults_count` TINYINT(1) NOT NULL DEFAULT 1,
  `children_count` TINYINT(1) NOT NULL DEFAULT 0,
  `price` DECIMAL(5,2) NOT NULL DEFAULT 0,
  `paid` TINYINT(1) NOT NULL DEFAULT 0,
  `client_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_reservation_room_id`
    FOREIGN KEY (`room_id`)
    REFERENCES `booking`.`room` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_reservation_client_id`
    FOREIGN KEY (`client_id`)
    REFERENCES `booking`.`client` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `id_UNIQUE` ON `booking`.`reservation` (`id` ASC);

CREATE INDEX `fk_reservation_room_id_idx` ON `booking`.`reservation` (`room_id` ASC);

CREATE INDEX `fk_reservation_client_id_idx` ON `booking`.`reservation` (`client_id` ASC);


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
