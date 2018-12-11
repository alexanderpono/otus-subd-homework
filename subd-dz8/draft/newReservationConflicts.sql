drop FUNCTION if exists newReservationConflicts(new_start_date date, new_end_date date);

CREATE or replace FUNCTION newReservationConflicts(new_start_date date, new_end_date date)
	RETURNS boolean AS
$BODY$
DECLARE 
	new_start_inside_reservation integer;
	new_end_inside_reservation integer;
	myResult boolean;
BEGIN
    DROP TABLE IF EXISTS booking.tmp_table;
    DROP TABLE IF EXISTS booking.tmp_table2;
	CREATE TABLE booking.tmp_table(varName varchar(255), val varchar(255));

	SELECT id 
	from booking.reservation
	WHERE (booking.reservation.start_date <= new_start_date) and (new_start_date < booking.reservation.end_date)
	into new_start_inside_reservation
	;

	SELECT id 
	from booking.reservation
	WHERE (booking.reservation.start_date <= new_end_date) and (new_end_date < booking.reservation.end_date)
	into new_end_inside_reservation
	;

	select 
		(new_start_inside_reservation is not null) or (new_end_inside_reservation is not null) 
   	into myResult
	;
	
	
--	insert into booking.tmp_table(varName, val) 
--	values
--		('new_start_date', new_start_date),
--		('new_end_date', new_end_date),
--		('new_start_inside_reservation', new_start_inside_reservation),
--		('new_end_inside_reservation', new_end_inside_reservation),
--		('myResult', myResult)
--	;
--
	return myResult;
	
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;

select newReservationConflicts('2018-05-09', '2018-05-12'); 


