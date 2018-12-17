drop FUNCTION if exists booking.newReservationConflicts(room_id1 integer, new_start_date date, new_end_date date);
drop FUNCTION if exists booking.checkNewReservationConflicts() cascade;

CREATE or replace FUNCTION booking.newReservationConflicts(room_id1 integer, new_start_date date, new_end_date date)
	RETURNS boolean AS
$BODY$
DECLARE 
	new_start_inside_reservation integer;
	new_end_inside_reservation integer;
	myResult boolean;
BEGIN
	SELECT id 
	from booking.reservation
	WHERE 
		(booking.reservation.start_date <= new_start_date) and 
		(new_start_date < booking.reservation.end_date) and
		(booking.reservation.room_id = room_id1)
	into new_start_inside_reservation
	;

	SELECT id 
	from booking.reservation
	WHERE 
		(booking.reservation.start_date <= new_end_date) and 
		(new_end_date < booking.reservation.end_date) and
		(booking.reservation.room_id = room_id1)
	into new_end_inside_reservation
	;

	select 
		(new_start_inside_reservation is not null) or (new_end_inside_reservation is not null) 
   	into myResult
	;
	
	return myResult;
	
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;


CREATE or replace FUNCTION booking.checkNewReservationConflicts() RETURNS trigger AS $$
declare
	conflictFound boolean;
	s varchar;
begin

	select booking.newReservationConflicts(new.room_id, new.start_date, new.end_date) into conflictFound;
   	if conflictFound is true then
   		RAISE EXCEPTION 
   			'new reservation (%) - (%) for room id="%" conflicts with existing ones', 
   				new.start_date, 
   				new.end_date, 
   				new.room_id;
   	end if;

    RETURN NEW;
end;
$$ LANGUAGE plpgsql;


drop trigger if exists reservation_BEFORE_INSERT ON booking.reservation;

CREATE TRIGGER reservation_BEFORE_INSERT BEFORE INSERT OR UPDATE ON booking.reservation
    FOR EACH ROW EXECUTE PROCEDURE booking.checkNewReservationConflicts();


