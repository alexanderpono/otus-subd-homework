SELECT * FROM pg_tablespace;

show data_directory;

#CREATE TABLESPACE tablespace2 LOCATION '/var/tablespace2';
# \i /mnt/bootstrap/init-db.sql

@new_start_date = '2018-05-05';

@new_end_date = '2018-05-11';
SET @new_start_inside_reservation = (
	SELECT id 
	FROM booking.reservation r
	WHERE r.start_date <= @new_start_date  and @new_start_date <= r.end_date 
);



create or replace function getmy() returns record as $$
declare my record;
begin
   select 15::int as int_field, 10.76::numeric as float_field, 'Yohoho!!!'::text as text_field into my;
   return my;
end $$ language 'plpgsql';
select * from getmy() as ROW(int_field int, float_field numeric, text_field text);


CREATE PROCEDURE insert_data(a integer, b integer)
LANGUAGE SQL
AS $$
INSERT INTO tbl VALUES (a);
INSERT INTO tbl VALUES (b);
$$;

CREATE FUNCTION MyInsert(_sno integer, _eid integer, _sd date, _ed date, _sid integer, _status boolean)
  RETURNS void AS
  $BODY$
      BEGIN
        INSERT INTO app_for_leave(sno, eid, sd, ed, sid, status)
        VALUES(_sno, _eid, _sd, _ed, _sid, _status);
      END;
  $BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
  
 
DO $$
DECLARE myvar integer;
BEGIN
    SELECT 2 INTO myvar;

    DROP TABLE IF EXISTS booking.tmp_table;
    CREATE TABLE booking.tmp_table AS
    	SELECT * FROM booking.city WHERE   id = myvar;
END $$;

SELECT * FROM booking.tmp_table;


DO $$
DECLARE 
	new_start_date date;
	new_end_date date;
	new_start_inside_reservation integer;
	new_end_inside_reservation integer;
BEGIN
    SELECT '2018-05-05' INTO new_start_date;
    SELECT '2018-05-11' INTO new_end_date;

    DROP TABLE IF EXISTS booking.tmp_table;
    DROP TABLE IF EXISTS booking.tmp_table2;
--    CREATE TABLE booking.tmp_table AS
--    	SELECT * FROM booking.city WHERE   id = myvar;
	CREATE TABLE booking.tmp_table(varName varchar(255), val varchar(255));

--	into new_start_inside_reservation
-- (booking.reservation.start_date <= new_start_date) and (new_start_date <= booking.reservation.end_date)
--	WHERE reservation.start_date >= '2000-10-10'
	
--	CREATE TABLE booking.tmp_table2 AS
--		SELECT id 
--		from booking.reservation
--		WHERE (booking.reservation.start_date < new_start_date) and (new_start_date < booking.reservation.end_date)
--	;

	SELECT id 
	from booking.reservation
	WHERE (booking.reservation.start_date < new_start_date) and (new_start_date < booking.reservation.end_date)
	into new_start_inside_reservation
	;

	SELECT id 
	from booking.reservation
	WHERE (booking.reservation.start_date < new_end_date) and (new_end_date < booking.reservation.end_date)
	into new_end_inside_reservation
	;

	insert into booking.tmp_table(varName, val) 
	values
		('new_start_date', new_start_date),
		('new_end_date', new_end_date),
		('new_start_inside_reservation', new_start_inside_reservation),
		('new_end_inside_reservation', new_end_inside_reservation)
	;

END $$;

@new_start_date = '2018-05-05';

@new_end_date = '2018-05-11';
SET @new_start_inside_reservation = (
	SELECT id 
	FROM booking.reservation r
	WHERE r.start_date <= @new_start_date  and @new_start_date <= r.end_date 
);



DO $$
DECLARE 
	new_start_date date;
	new_end_date date;
	new_start_inside_reservation integer;
	new_end_inside_reservation integer;
BEGIN
    SELECT '2018-05-05' INTO new_start_date;
    SELECT '2018-05-11' INTO new_end_date;

    DROP TABLE IF EXISTS booking.tmp_table;
    DROP TABLE IF EXISTS booking.tmp_table2;
--    CREATE TABLE booking.tmp_table AS
--    	SELECT * FROM booking.city WHERE   id = myvar;
	CREATE TABLE booking.tmp_table(varName varchar(255), val varchar(255));

--	into new_start_inside_reservation
-- (booking.reservation.start_date <= new_start_date) and (new_start_date <= booking.reservation.end_date)
--	WHERE reservation.start_date >= '2000-10-10'
	
--	CREATE TABLE booking.tmp_table2 AS
--		SELECT id 
--		from booking.reservation
--		WHERE (booking.reservation.start_date < new_start_date) and (new_start_date < booking.reservation.end_date)
--	;

	SELECT id 
	from booking.reservation
	WHERE (booking.reservation.start_date < new_start_date) and (new_start_date < booking.reservation.end_date)
	into new_start_inside_reservation
	;

	SELECT id 
	from booking.reservation
	WHERE (booking.reservation.start_date < new_end_date) and (new_end_date < booking.reservation.end_date)
	into new_end_inside_reservation
	;

	insert into booking.tmp_table(varName, val) 
	values
		('new_start_date', new_start_date),
		('new_end_date', new_end_date),
		('new_start_inside_reservation', new_start_inside_reservation),
		('new_end_inside_reservation', new_end_inside_reservation)
	;

END $$;


insert into booking.reservation(room_id, client_id, start_date, end_date, adults_count, children_count, price, paid)
values 
	(1, 3, '2018-05-13', '2018-05-14', 2, 0, 36000, true)
;

insert into booking.reservation(room_id, client_id, start_date, end_date, adults_count, children_count, price, paid)
values 
	(1, 3, '2018-05-05', '2018-05-12', 2, 0, 36000, true)
;

