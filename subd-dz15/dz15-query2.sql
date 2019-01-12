#исходный запрос в виде представления:
create or replace view blog_db.v_simple_where as
	select * 
	from blog_db.`user` u
	where u.id in (
		select id 
		from blog_db.`user`
		where id>=2 and id<=5
	)
;
select *
from blog_db.v_simple_where
;

#план исходного запроса
explain 
	select * 
	from blog_db.`user` u
	where u.id in (
		select id 
		from blog_db.`user`
		where id>=2 and id<=5
	)
;

#план доработанного запроса после доработки
explain 
select * 
from blog_db.`user` u
where id>=2 and id<=5
;