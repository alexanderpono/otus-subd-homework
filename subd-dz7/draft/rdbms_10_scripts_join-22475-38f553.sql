select *
from public.ships;

select *
from public.battle;

--cross join
select *
from public.ships, public.battle;

select * 
from public.ships
  cross join public.battle;
  
--inner join 
select * 
from public.ships as ships, public.battle as battle
where ships.shipname = battle.shipname;

select * 
from public.ships as ships
	join public.battle as battle
		on ships.shipname = battle.shipname;
		
select * 
from public.ships as ships
	inner join public.pirates as pirates
		on ships.shipname = pirates.shipname
			and ships.piratecount > pirates.id;
	
		
--left join 
select * 
from public.ships as ships
	left join public.battle as battle
		on ships.shipname = battle.shipname;
		
create table items (iname varchar(50), icount int);

create table sell (iname varchar(50), sell_count int);

create table items_description (iname varchar(50), manufactor varchar(150), date_created date);

insert into items_description(iname, manufactor, date_created)
select distinct iname, 'China', now()
from items;

select * 
from items_description as itd
	inner join sell 
		on sell.iname = itd.iname
	inner join items 
		on items.iname = sell.iname;
		
select * 
from items_description as itd
	left join sell 
		on sell.iname = itd.iname
	inner join items 
		on items.iname = sell.iname;

insert into items (iname, icount)
values ('яблоки',1),('груши',3),('сливы',4),('мандарины',10),('виноград',7);

insert into items (iname, icount)
values ('яблоки',99)

insert into sell (iname, sell_count)
values ('урюк',8),('груши',1),('яблоки',1),('стул',1);

select * from items;
select * from sell;

select *
from items
	left join sell 
		on items.iname = sell.iname;
		
select *
from items
	right join sell 
		on items.iname = sell.iname;
		
--right join 		
select * 
from public.ships as ships
	right join public.pirates as pirates
		on ships.shipname = pirates.shipname;
		
--full join
select * 
from public.ships as ships
	full join public.pirates as pirates
		on ships.shipname = pirates.shipname;

select * 
from public.ships as ships
	join public.pirates as pirates
		on ships.shipname = pirates.shipname
	join public.piratebattle as battle
		on battle.piratename = pirates.piratename;
		
select * 
from public.ships as ships
	left join public.pirates as pirates
		on ships.shipname = pirates.shipname
	join public.piratebattle as battle
		on battle.piratename = pirates.piratename;		
		
select * 
from public.ships as ships
	left join public.pirates as pirates
		on ships.shipname = pirates.shipname
	left join public.piratebattle as battle
		on battle.piratename = pirates.piratename;	
		
select * 
from public.pirates as pirates
	inner join public.piratebattle as battle
		on battle.piratename = pirates.piratename
	right join public.ships as ships
		on ships.shipname = pirates.shipname;	
		
--извращения
select * 
from public.ships as ships
	join public.battle as battle
		on piratecount > 0;
