#использование подзапроса в WHERE
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

explain 
	select * 
	from blog_db.`user` u
	where u.id in (
		select id 
		from blog_db.`user`
		where id>=2 and id<=5
	)
;


explain 
select * 
from blog_db.`user` u
where id>=2 and id<=5
;