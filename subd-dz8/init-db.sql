DROP SCHEMA IF EXISTS booking cascade;

CREATE SCHEMA IF NOT EXISTS booking authorization myapp;

-- -----------------------------------------------------
-- Table `booking`.`city`
-- -----------------------------------------------------
CREATE SEQUENCE booking.city_seq;
CREATE TABLE IF NOT EXISTS booking.city (
  id INT NOT NULL DEFAULT nextval('booking.city_seq'),
  name VARCHAR(45) NOT NULL,
  PRIMARY KEY (id))
 ;

CREATE UNIQUE INDEX city_id_UNIQUE ON booking.city (id ASC);

-- -----------------------------------------------------
-- Table `booking`.`hotel`
-- -----------------------------------------------------
CREATE SEQUENCE booking.hotel_seq;
CREATE TABLE IF NOT EXISTS booking.hotel (
  id INT NOT NULL DEFAULT nextval('booking.hotel_seq'),
  address VARCHAR(128) NOT NULL,
  city_id INT NOT NULL,
  name VARCHAR(45) NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_hotel_city_id
    FOREIGN KEY (city_id)
    REFERENCES booking.city (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
;

CREATE UNIQUE INDEX hotel_id_UNIQUE ON booking.hotel (id ASC);

CREATE INDEX fk_hotel_city_id_idx ON booking.hotel (city_id ASC);


-- -----------------------------------------------------
-- Table `booking`.`room_type`
-- -----------------------------------------------------
CREATE SEQUENCE booking.room_type_seq;
CREATE TABLE IF NOT EXISTS booking.room_type (
  id INT NOT NULL DEFAULT nextval('booking.room_type_seq'),
  hotel_id INT NOT NULL,
  caption VARCHAR(100) NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_room_type_hotel_id
    FOREIGN KEY (hotel_id)
    REFERENCES booking.hotel (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
;

CREATE UNIQUE INDEX room_type_id_UNIQUE ON booking.room_type (id ASC);


-- -----------------------------------------------------
-- Table `booking`.`room`
-- -----------------------------------------------------
CREATE SEQUENCE booking.room_seq;
CREATE TABLE IF NOT EXISTS booking.room (
  id INT NOT NULL DEFAULT nextval('booking.room_seq'),
  description VARCHAR(1024) NOT NULL,
  adults_count smallint NOT NULL,
  room_type_id INT NOT NULL,
  hotel_id INT NOT NULL,
  square DECIMAL(3,1) NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_room_room_type_id
    FOREIGN KEY (room_type_id)
    REFERENCES booking.room_type (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_room_hotel_id
    FOREIGN KEY (hotel_id)
    REFERENCES booking.hotel (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
;

CREATE UNIQUE INDEX room_id_UNIQUE ON booking.room (id ASC);

CREATE INDEX fk_room_room_type_id_idx ON booking.room (room_type_id ASC);

CREATE INDEX fk_room_hotel_id_idx ON booking.room (hotel_id ASC);


-- -----------------------------------------------------
-- Table `booking`.`room_attribute`
-- -----------------------------------------------------
CREATE SEQUENCE booking.room_attribute_seq;
CREATE TABLE IF NOT EXISTS booking.room_attribute (
  id INT NOT NULL DEFAULT nextval('booking.room_attribute_seq'),
  caption VARCHAR(45) NOT NULL,
  PRIMARY KEY (id))
;

CREATE UNIQUE INDEX room_attribute_id_UNIQUE ON booking.room_attribute (id ASC);


-- -----------------------------------------------------
-- Table `booking`.`room_has_attribute`
-- -----------------------------------------------------
CREATE SEQUENCE booking.room_has_attribute_seq;
CREATE TABLE IF NOT EXISTS booking.room_has_attribute (
  id INT NOT NULL DEFAULT nextval('booking.room_has_attribute_seq'),
  room_id INT NOT NULL,
  room_attribute_id INT NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_room_has_attribute_room_attr_id
    FOREIGN KEY (room_attribute_id)
    REFERENCES booking.room_attribute (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_room_has_attribute_room_id
    FOREIGN KEY (room_id)
    REFERENCES booking.room (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
;

CREATE UNIQUE INDEX room_has_attribute_id_UNIQUE ON booking.room_has_attribute (id ASC);

CREATE INDEX fk_room_has_attribute_room_attr_id_idx ON booking.room_has_attribute (room_attribute_id ASC);

CREATE INDEX fk_room_has_attribute_room_id_idx ON booking.room_has_attribute (room_id ASC);


-- -----------------------------------------------------
-- Table `booking`.`time_template`
-- -----------------------------------------------------
CREATE SEQUENCE booking.time_template_seq;
CREATE TABLE IF NOT EXISTS booking.time_template (
  id INT NOT NULL DEFAULT nextval('booking.time_template_seq'),
  start_month smallint NOT NULL,
  start_day smallint NOT NULL,
  end_month smallint NOT NULL,
  end_day smallint NOT NULL,
  PRIMARY KEY (id))
;

CREATE UNIQUE INDEX time_template_id_UNIQUE ON booking.time_template (id ASC);


-- -----------------------------------------------------
-- Table `booking`.`price`
-- -----------------------------------------------------
CREATE SEQUENCE booking.price_seq;
CREATE TABLE IF NOT EXISTS booking.price (
  id INT NOT NULL DEFAULT nextval('booking.price_seq'),
  room_id INT NOT NULL,
  start_month smallint NOT NULL DEFAULT 0,
  start_day smallint NOT NULL DEFAULT 0,
  end_month smallint NOT NULL DEFAULT 0,
  end_day smallint NOT NULL DEFAULT 0,
  base_price DECIMAL(8,2) NOT NULL,
  add_child_price DECIMAL(8,2) NOT NULL DEFAULT 0,
  time_template_id INT NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  CONSTRAINT fk_price_room_id
    FOREIGN KEY (room_id)
    REFERENCES booking.room (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_price_time_template_id
    FOREIGN KEY (time_template_id)
    REFERENCES booking.time_template (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
;

CREATE UNIQUE INDEX price_id_UNIQUE ON booking.price (id ASC);

CREATE INDEX fk_price_room_id_idx ON booking.price (room_id ASC);

CREATE INDEX fk_price_time_template_id_idx ON booking.price (time_template_id ASC);


-- -----------------------------------------------------
-- Table `booking`.`photo`
-- -----------------------------------------------------
CREATE SEQUENCE booking.photo_seq;
CREATE TABLE IF NOT EXISTS booking.photo (
  id INT NOT NULL DEFAULT nextval('booking.photo_seq'),
  file_name VARCHAR(45) NOT NULL,
  room_id INT NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_photo_room_id
    FOREIGN KEY (room_id)
    REFERENCES booking.room (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
;

CREATE UNIQUE INDEX id_UNIQUE ON booking.photo (id ASC);

CREATE INDEX fk_photo_room_id_idx ON booking.photo (room_id ASC);


-- -----------------------------------------------------
-- Table `booking`.`client`
-- -----------------------------------------------------
CREATE SEQUENCE booking.client_seq;
CREATE TABLE IF NOT EXISTS booking.client (
  id INT NOT NULL DEFAULT nextval('booking.client_seq'),
  first_name VARCHAR(45) NOT NULL,
  email VARCHAR(45) NOT NULL,
  phone_number VARCHAR(20) NOT NULL DEFAULT '',
  password char(32) NOT NULL,
  email_confirmed boolean NOT NULL DEFAULT FALSE,
  last_name VARCHAR(45) NOT NULL DEFAULT '',
  PRIMARY KEY (id))
;

CREATE UNIQUE INDEX client_id_UNIQUE ON booking.client (id ASC);


-- -----------------------------------------------------
-- Table `booking`.`reservation`
-- -----------------------------------------------------
CREATE SEQUENCE booking.reservation_seq;
CREATE TABLE IF NOT EXISTS booking.reservation (
  id INT NOT NULL DEFAULT nextval('booking.reservation_seq'),
  room_id INT NOT NULL,
  client_id INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  adults_count smallint NOT NULL DEFAULT 1,
  children_count smallint NOT NULL DEFAULT 0,
  price DECIMAL(8,2) NOT NULL DEFAULT 0,
  paid boolean NOT NULL DEFAULT FALSE,
  PRIMARY KEY (id),
  CONSTRAINT fk_reservation_room_id
    FOREIGN KEY (room_id)
    REFERENCES booking.room (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_reservation_client_id
    FOREIGN KEY (client_id)
    REFERENCES booking.client (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
;

CREATE UNIQUE INDEX reservation_id_UNIQUE ON booking.reservation (id ASC);

CREATE INDEX fk_reservation_room_id_idx ON booking.reservation (room_id ASC);

CREATE INDEX fk_reservation_client_id_idx ON booking.reservation (client_id ASC);


ALTER TABLE booking.client SET TABLESPACE tablespace2;


insert into booking.city(id, name)
values (1, 'Москва'), (2, 'Санкт-Петербург'), (3, 'Тверь')
;
ALTER SEQUENCE booking.city_seq MINVALUE 4 START 4 RESTART 4;


insert into booking.client(id, first_name, email, phone_number, "password", email_confirmed, last_name)
values 
	(1, 'Вася', 'vasya@mail.ru', '+79161001010', '1111111', true, 'Петров'),
	(2, 'Петя', 'petya@mail.ru', '+79162002020', '2222222', true, 'Васильев'),
	(3, 'Катя', 'katya@mail.ru', '+79163003030', '3333333', false, 'Алешина')
;
ALTER SEQUENCE booking.client_seq MINVALUE 4 START 4 RESTART 4;


insert into booking.hotel(id, city_id, name, address)
values 
	(1, 1, 'Гостиница Альфа Измайлово', 'Измайловское шоссе 71 корпус А, Измайлово, Москва, Россия'),
	(2, 1, 'Гостиница Вега Измайлово', 'Измайловское шоссе 71 строение 3В, Измайлово, Москва, Россия'),
	(3, 2, 'АЗИМУТ Отель Санкт-Петербург', 'Лермонтовский Проспект 43/1, Адмиралтейский район, Санкт-Петербург, Россия')
;
ALTER SEQUENCE booking.hotel_seq MINVALUE 4 START 4 RESTART 4;


insert into booking.room_attribute(id, caption)
values 
	(1, 'Мини-бар'),
	(2, 'Сейф'),
	(3, 'Телевизор'),
	(4, 'Телефон'),
	(5, 'Кондиционер')
;
ALTER SEQUENCE booking.room_attribute_seq MINVALUE 6 START 6 RESTART 6;


insert into booking.room_type(id, hotel_id, caption)
values 
	(1, 1, 'Стандартный двухместный номер с 1 кроватью'),
	(2, 1, 'Полулюкс'),
	(3, 1, 'Улучшенный двухместный номер с 1 кроватью или 2 отдельными кроватями'),
	(4, 1, 'Двухместный номер «Комфорт» с 1 кроватью'),
	(5, 1, 'Стандартный двухместный номер с 2 отдельными кроватями'),	
	(6, 2, 'Двухместный номер Делюкс с 2 отдельными кроватями'),
	(7, 2, 'Стандартный двухместный номер с 2 отдельными кроватями'),
	(8, 2, 'Двухместный номер Делюкс с 1 кроватью'),
	(9, 2, 'Стандартный двухместный номер с 1 кроватью'),
	(10, 2, 'Стандартный семейный номер'),	
	(11, 3, 'Стандартный двухместный номер SMART с 1 кроватью или 2 отдельными кроватями'),
	(12, 3, 'Полулюкс SMART'),
	(13, 3, 'Уютный одноместный номер')
;
ALTER SEQUENCE booking.room_type_seq MINVALUE 14 START 14 RESTART 14;


insert into booking.room(id, hotel_id, room_type_id, adults_count, description, square)
values 
	(1, 1, 1, 2, 'Классический номер с кабельным телевидением и бесплатным Wi-Fi. ', 21.0),
	(2, 1, 2, 2, 'Очень просторный номер с бесплатным Wi-Fi и большим мебельным уголком с удобным диваном. ', 42.0),
	(3, 1, 3, 2, 'Классический номер с кабельным телевидением и бесплатным Wi-Fi. ', 21.0),

	(4, 2, 6, 2, 'Номер с кондиционером, 2 отдельными кроватями, телевизором с плоским экраном и спутниковыми каналами, столом, холодильником и сейфом. В каждом номере есть собственная ванная комната с бесплатными туалетно-косметическими принадлежностями, халатами и тапочками. ', 21.0),
	(5, 2, 7, 2, 'Номер с 2 отдельными кроватями, телевизором с плоским экраном и спутниковыми каналами, столом, холодильником и сейфом. В каждом номере есть собственная ванная комната с бесплатными туалетно-косметическими принадлежностями, халатами и тапочками.', 21.0),
	(6, 2, 8, 2, 'Номер с кондиционером, кроватью размера «king-size», телевизором с плоским экраном и спутниковыми каналами, столом, холодильником и сейфом. В каждом номере есть собственная ванная комната с бесплатными туалетно-косметическими принадлежностями, халатами и тапочками.', 21.0),

	(7, 3, 11, 2, 'В этом номере есть телевизор с плоским экраном, сейф и собственная ванная комната с тропическим душем.

В числе удобств фен. Из некоторых номеров открывается панорамный вид на Санкт-Петербург. ', 21.0),
	(8, 3, 12, 2, 'Полулюкс с двуспальной кроватью, халатами и кондиционером.

Номер располагает 1 большой комнатой или 2 менее просторными комнатами. ', 21.0),
	(9, 3, 13, 1, 'В этом звукоизолированном одноместном номере установлен телевизор с плоским экраном. ', 21.0)
;
ALTER SEQUENCE booking.room_seq MINVALUE 10 START 10 RESTART 10;


insert into booking.room_has_attribute(id, room_id, room_attribute_id)
values 
	(1, 1, 1),
	(2, 1, 2),
	(3, 1, 3),
	(4, 2, 1),
	(5, 2, 4),
	(6, 2, 5),
	(7, 3, 2),
	(8, 3, 3),
	(9, 3, 4),
	(10, 4, 1),
	(11, 4, 2),
	(12, 5, 2),
	(13, 5, 3),
	(14, 6, 4),
	(15, 6, 5),
	(16, 7, 1),
	(17, 8, 2),
	(18, 9, 3)
;
ALTER SEQUENCE booking.room_has_attribute_seq MINVALUE 19 START 19 RESTART 19;


insert into booking.photo(id, room_id, file_name)
values 
	(1, 1, '1.jpg'),
	(2, 1, '13.jpg'),
	(3, 2, '1453.jpg'),
	(4, 3, '164.jpg'),
	(5, 4, '1564.jpg'),
	(6, 5, '15.jpg'),
	(7, 6, '1456.jpg'),
	(8, 7, '145.jpg'),
	(9, 8, '15646.jpg'),
	(10, 9, '1as.jpg')
;
ALTER SEQUENCE booking.photo_seq MINVALUE 11 START 11 RESTART 11;


insert into booking.time_template(id, start_month, start_day, end_month, end_day)
values 
	(1, 12, 1, 2, 28),
	(2, 3, 1, 5, 31),
	(3, 6, 1, 8, 31),
	(4, 9, 1, 11, 30),
	(5, 12, 1, 12, 20),
	(6, 12, 21, 1, 10),
	(7, 1, 11, 2, 28),
	(8, 1, 1, 12, 31)
;
ALTER SEQUENCE booking.time_template_seq MINVALUE 9 START 9 RESTART 9;


insert into booking.price(id, room_id, time_template_id, start_month, start_day, end_month, end_day, base_price, add_child_price)
values 
	(1, 1, 5, 0, 0, 0, 0, 3000, 500),
	(2, 1, 6, 0, 0, 0, 0, 6000, 1000),
	(3, 1, 7, 0, 0, 0, 0, 3000, 500),
	(4, 1, 2, 0, 0, 0, 0, 4000, 500),
	(5, 1, 3, 0, 0, 0, 0, 5000, 800),
	(6, 1, 4, 0, 0, 0, 0, 4000, 500),
	(7, 2, 8, 0, 0, 0, 0, 2000, 200),
	(8, 3, 8, 0, 0, 0, 0, 3000, 300),
	(9, 4, 8, 0, 0, 0, 0, 4000, 400),
	(10, 6, 8, 0, 0, 0, 0, 5000, 600),
	(11, 7, 8, 0, 0, 0, 0, 6000, 900),
	(12, 8, 8, 0, 0, 0, 0, 7000, 1500),
	(13, 9, 8, 0, 0, 0, 0, 8000, 2000)
;
ALTER SEQUENCE booking.price_seq MINVALUE 14 START 14 RESTART 14;


insert into booking.reservation(id, room_id, client_id, start_date, end_date, adults_count, children_count, price, paid)
values 
	(1, 1, 1, '2018-05-01', '2018-05-10', 2, 0, 36000, true),
	(2, 1, 2, '2018-05-15', '2018-05-17', 2, 0, 8000, false)
;
ALTER SEQUENCE booking.reservation_seq MINVALUE 3 START 3 RESTART 3;

