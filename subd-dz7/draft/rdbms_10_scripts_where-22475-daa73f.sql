select *
from public.ships
where shipname = 'Havana';

select * 
from public.ships
where shipsize > 30;

select * 
from public.ships
where shipsize > 30 and shipsize < 100;

select * 
from public.ships
where (shipsize between 56 and NULL)
	and (shipname = 'Havana')
	or (shipname = 'Jarding');

select * 
from public.ships
where shipsize >= 50 and shipsize <= 100;

select * 
from public.pirates
where shipname is not null
 and dateofdearth is null;
 

select * 
from public.pirates
where dateofbirth >= '2007-09-13'
	and dateofbirth < '2007-09-14'

select *,extract(YEAR from dateofbirth)
from public.pirates
where extract(YEAR from dateofbirth) > 1580;

select * ,age('16050101',dateofbirth)
from public.pirates;

select * 
from public.pirates
where shipname is not null
 or dateofdearth is null
 and shipname = 'Havana';
 
select *
from public.pirates
where piratename like '%c%';
select *
from public.pirates
where piratename like '_ack';
 
select *
from public.pirates
where piratename like '%Ja%';

select *
from public.pirates
where id in (select piratecount from public.ships);

select *
from public.pirates
where shipname = 'Jarding'
	or shipname = 'Black Pearl';

select * 
from public.pirates
where id = ANY (select piratecount from public.ships);

select * 
from public.items
where icount <= SOME (select sell_count from sell);

select * 
from public.items
where icount >= ALL (select sell_count from sell);

select * 
from (
select * 
from public.items as items
where exists (select 1 from sell where sell.iname = items.iname)) as ;

select * 
from public.items;
select * from sell;

select * 
from public.pirates
where shipname = ANY (select shipname from public.ships);



select * 
from public.pirates
where dateofdearth >= ANY (select dateofbirth from public.pirates);

var_name
var_count
var_date

select * 
from public.pirates
where ((var_name is null) or (piratename = var_name))
	or ((var_count is NULL) or (size = var_count))
	or ((var_date is NULL) or (dateofbirth > var_date))


