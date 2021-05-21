
select *
from rental r 
where r.return_date is null;


select * 
from rental r 
where date_part('year',r.rental_date) = 2006;

select count(*)
from rental r ;

select  distinct f.rental_rate 
from film f; 


select f.rental_rate
,      count(*)
from film f
group by 1;

select *
from film f
where f.rental_rate = 0.99 ; 

select * 
from film f 
where f.rental_rate = 4.99;


create temp table aktorzy_w__filmach
as
select fa.actor_id 
,      fa.film_id 
from film_actor fa 
where fa.film_id  in ( 

	select filmy.film_id 
	from (
			select i.film_id 
			,	   count(*) as liczba_wypozyczen	
			from rental r 
			join inventory i on r.inventory_id = i.inventory_id 
			where i.film_id != 257 and r.return_date is not null
			group by 1
		) filmy
)

select a.actor_id
,      count(*) as liczba_filmow
from aktorzy_w__filmach a
group by 1
order by 2 desc; 
