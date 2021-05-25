
select *
from rental r 
where r.return_date is null;


select * 
from rental r 
where date_part('year',r.rental_date) = 2006;


--- sprawdzam ile mamy uniklanych dziennych cen wypozyczen filmow  --- 

select  distinct f.rental_rate 
from film f; 

select f.rental_rate
,      count(*)
from film f
group by 1;

--- Rezultat: Mamy 3 ceny, liczba filmow rozlozona jest w miare rownomiernie

select *
from film f
where f.rental_rate = 0.99 ; 

select * 
from film f 
where f.rental_rate = 4.99;

--- Szukamy aktorow ktorzy graja w filamch o cenie dziennej 0.99 

create temp table aktorzy_mala_cena_dzienna
as
select fa.actor_id 
,      fa.film_id 
from film_actor fa 
where fa.film_id in (
	
	select f.film_id 
	from film f
	where f.rental_rate = 0.99  

) ;

select  adc.actor_id
,       count(*) as liczba_flimow
from aktorzy_mala_cena_dzienna adc
group by 1 
order by 2 desc;

--- Szukamy aktorow ktorzy graja w filmach o cenie dziennej 4.99

create temp table aktorzy_duza_cena_dzienna
as
select * 
from film_actor fa 
where fa.film_id in (
	
	select f.film_id 
	from film f
	where f.rental_rate = 4.99  
) 

select  adc.actor_id
,       count(*) as liczba_flimow
from aktorzy_duza_cena_dzienna adc
group by 1 
order by 2 desc;


create temp table aktorzy_srednia_cena_dzienna
as
select * 
from film_actor fa 
where fa.film_id in (
	
	select f.film_id 
	from film f
	where f.rental_rate = 2.99  
) 

select  aksc.actor_id
,       count(*) as liczba_flimow
from aktorzy_srednia_cena_dzienna aksc
group by 1 
order by 2 desc;



select count(*) 
from actor a ; --- 200 aktorow w bazie


--- Proba porowanania zbiorow 

select  actor_id
from aktorzy_mala_cena_dzienna --- cena: 0.99

intersect 

select  actor_id
from aktorzy_duza_cena_dzienna --- cena 4.99

--- Wynik : 200 aktorow co jest rowne ogolnej ilosci aktorow 
--- Wnika z tego ze aktor nie ma zbyt duzego wplywu na skrajne dzienne ceny wypozycen filmow 


select  actor_id
from aktorzy_mala_cena_dzienna --- cena 0.99

intersect 

select  actor_id
from aktorzy_srednia_cena_dzienna --- cena 2.99

--- Wynik : 200 aktorow co jest rowne ogolnej ilosci aktorow 
--- Wnika z tego ze aktor nie ma zbyt duzego wplywu na srednia i mala cene wypozyczen filmow 


select  actor_id
from aktorzy_srednia_cena_dzienna --- cena 2.99

intersect 

select  actor_id
from aktorzy_duza_cena_dzienna   --- cena 4.99

--- Wynik : 200 aktorow co jest rowne ogolnej ilosci aktorow 
--- Wnika z tego ze aktor nie ma zbyt duzego wplywu na duza i mala  ceny wypozycen filmow 



select fa.actor_id,
	   count(*)
from film_actor fa
where fa.actor_id  in (65,82,198,107)
group by 1 
order by 2 desc;


65,198,107