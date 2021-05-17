
select count(*) 
  from rental r ; --- 16 044

-- film id 257 

select * 
  from rental r ; 



select count(*)

select * 
from payment p 
where p.amount = 0;




--- tabela ktora podsumowuje nam ilosc wypozyczen filmu per jego id  ---
--- wyszlo 958 pozycji

select i.film_id 
,	   count(*) as liczba_wypozyczen	
from rental r 
join inventory i on r.inventory_id = i.inventory_id 
group by 1
order by 2 desc; 


--- tabela w ktorej przechowujemy dane statystyczne dotyczace powyzszej tabeli --

create temp table analiza
as 
select percentile_cont(0.10) within group ( order by liczba_wypozyczen ) as q_10
,	   percentile_cont(0.25) within group ( order by liczba_wypozyczen ) as q_25
,	   percentile_cont(0.50) within group ( order by liczba_wypozyczen ) as mediana
,      percentile_cont(0.75) within group ( order by liczba_wypozyczen ) as q_75
,	   percentile_cont(0.90) within group ( order by liczba_wypozyczen ) as q_90
,      round(avg(liczba_wypozyczen),2) as srednia_liczba_wypozyczen
,      mode() within group ( order by liczba_wypozyczen ) as moda
,      min(liczba_wypozyczen) as minimalna_liczba_wypozyczen
,      max(liczba_wypozyczen) as maksymalna_liczba_wypozyczen
from 
(
	select i.film_id 
	,	   count(*) as liczba_wypozyczen	
	from rental r 
	join inventory i on r.inventory_id = i.inventory_id 
	group by 1
) zestawienie_wypozyczen


--- filmy wraz z aktorami ktore wpadaja w graniczne przedzialy pod katem liczby wypozyczen - kwantyle 0.25 oraz 0.75 ---
--------------------------------------------------------------------------------------------------------

--- kwantyl 0.25 -- aktorzy wraz z najmniej wypozyczanymi filmami , liczba wypozyczen mniejsza niz 25 % z wszystkich liczb wypozyczen filmow   ---

create temp table aktorzy_w_najrzadziej_wypozyczanych_filmach
as
select fa.actor_id 
,      fa.film_id 
from film_actor fa 
where fa.film_id  in ( 

	select filmy_najrzadsze.film_id 
	from (
			select i.film_id 
			,	   count(*) as liczba_wypozyczen	
			from rental r 
			join inventory i on r.inventory_id = i.inventory_id 
			where i.film_id != 257
			group by 1
			having count(*) <= ( 
		                     	 select q_25
		                      		from analiza
		                       )
		) filmy_najrzadsze 
)


--- aktorzy ktorzy wybiajaja sie na poczatek listy 

create temp table top_20_aktorow_najrzadziej_wypozyczane_filmy
as
select actor_id, 
       count(*) as liczba_filmow
from aktorzy_w_najrzadziej_wypozyczanych_filmach
group by 1 
order by 2 desc
limit 20;

select actor_id, 
       count(*) as liczba_filmow
from aktorzy_w_najrzadziej_wypozyczanych_filmach
group by 1 
order by 1;

--- kwantyl 0.75 -- aktorzy wraz z najczesciej wypozyczanymi filmami , liczba wypozyczen wieksza niz 75 % z wszystkich liczb wypozyczen filmow ---

select i.film_id 
,	   count(*) as liczba_wypozyczen	
from rental r 
join inventory i on r.inventory_id = i.inventory_id 
where i.film_id != 257
group by 1
having count(*) >= (
                      ( 
                        select q_75
                       from analiza 
                      )
)
order by 2 desc;


create temp table aktorzy_w_najczesciej_wypozyczanych_filmach
as
select fa.actor_id 
,      fa.film_id 
from film_actor fa 
where fa.film_id  in ( 

	select filmy_najczestsze.film_id 
	from (
			select i.film_id 
			,	   count(*) as liczba_wypozyczen	
			from rental r 
			join inventory i on r.inventory_id = i.inventory_id 
			where i.film_id != 257
			group by 1
			having count(*) >= ( 
		                     	 select q_75
		                      		from analiza
		                       )
		) filmy_najczestsze
)



--- aktorzy ktorzy wyibiaja sie na poczatek listy 

create temp table top_20_aktorow_najczesciej_wypozyczane_filmy
as
select actor_id, 
	  count(*) as liczba_filmow
from aktorzy_w_najczesciej_wypozyczanych_filmach
group by 1 
order by 2 desc
limit 20;

select actor_id, 
       count(*) as liczba_filmow
from aktorzy_w_najczesciej_wypozyczanych_filmach
group by 1 
order by 1;

--- proba porownania danych pod katem wystepowania aktorow zarowno w filmach najmniej wypozyczanych jak i najbardziej wypozyczanych ---


select actor_id 
from top_20_aktorow_najrzadziej_wypozyczane_filmy

intersect

select actor_id 
from top_20_aktorow_najczesciej_wypozyczane_filmy;

--- Wyniki analizy: w czesci wspolnej mamy tylko 2 rekordy 65 i 198
--- Wynika z tego ze ktorzy 

select *
from top_20_aktorow_najrzadziej_wypozyczane_filmy
where actor_id in (65,198);

select *
from top_20_aktorow_najczesciej_wypozyczane_filmy
where actor_id in (65,198);

--- analiza pozyzszych danych pod katem kategorii filmow w jakicjh wsytepowal aktor  --- 

	

--- filmy wraz z aktorami ktore wpadaja w graniczne przedzialy pod katem liczby wypozycze - kwantyle 0.10 oraz 0.90 ---
--------------------------------------------------------------------------------------------------------- 
--- kwantyl 0.10 -- aktorzy wraz z najmniej wypozyczanymi filmami , liczba wypozyczen mniejsza niz 10 % z wszystkich liczb wypozyczen filmow   ---

create temp table aktorzy_w_najrzadziej_wypozyczanych_filmach_2
as
select fa.actor_id 
,      fa.film_id 
from film_actor fa 
where fa.film_id  in ( 

	select filmy_najrzadsze.film_id 
	from (
			select i.film_id 
			,	   count(*) as liczba_wypozyczen	
			from rental r 
			join inventory i on r.inventory_id = i.inventory_id 
			where i.film_id != 257
			group by 1
			having count(*) <= ( 
		                     	 select q_10
		                      		from analiza
		                       )
		) filmy_najrzadsze 
)



--- aktorzy ktorzy wybiajaja sie na prowadzenie

create temp table top_20_aktorow_najrzadziej_wypozyczane_filmy_2
as
select actor_id, 
       count(*) as liczba_filmow
from aktorzy_w_najrzadziej_wypozyczanych_filmach_2
group by 1 
order by 2 desc
limit 20;

select actor_id, 
       count(*) as liczba_filmow
from aktorzy_w_najrzadziej_wypozyczanych_filmach_2
group by 1 
order by 1;



--- kwantyl 0.90 -- aktorzy wraz z najczesciej wypozyczanymi filmami , liczba wypozyczen mniejsza niz 90 % z wszystkich liczb wypozyczen filmow   ---


create temp table aktorzy_w_najczesciej_wypozyczanych_filmach_2
as
select fa.actor_id 
,      fa.film_id 
from film_actor fa 
where fa.film_id  in ( 

	select filmy_najczestsze.film_id 
	from (
			select i.film_id 
			,	   count(*) as liczba_wypozyczen	
			from rental r 
			join inventory i on r.inventory_id = i.inventory_id 
			where i.film_id != 257
			group by 1
			having count(*) >= ( 
		                     	 select q_90
		                      		from analiza
		                       )
		) filmy_najczestsze
)


create temp table top_20_aktorow_najczesciej_wypozyczane_filmy_2
as
select actor_id, 
	  count(*) as liczba_filmow
from aktorzy_w_najczesciej_wypozyczanych_filmach_2
group by 1 
order by 2 desc
limit 20;

select actor_id, 
       count(*) as liczba_filmow
from aktorzy_w_najczesciej_wypozyczanych_filmach_2
group by 1 
order by 1;


--- proba porownania danych pod katem wystepowania aktorow zarowno w filmach najmniej wypozyczanych jak i najbardziej wypozyczanych ---

select actor_id 
from top_20_aktorow_najrzadziej_wypozyczane_filmy_2

intersect

select actor_id 
from top_20_aktorow_najczesciej_wypozyczane_filmy_2;


--- Wyniki analizy: w czesci wspolnej mamy tylko 2 rekordy 65,90  i55

select *
from top_20_aktorow_najrzadziej_wypozyczane_filmy
join actor a2 on top_20_aktorow_najrzadziej_wypozyczane_filmy.actor_id = a2.actor_id 
where actor_id in (65,90,155);

select *
from top_20_aktorow_najczesciej_wypozyczane_filmy
where actor_id in (65,90,155);


--- analiza pozyzszych danych pod katem kategorii filmow w jakicjh wsytepowal aktor  --- 

--- kwantyle 0.25 oraz 0.75  

select * 
from category c ; -- mamy 16 kategorii filmow 

select fc.film_id 
,	   c."name" 
from film_category fc 
join category c  on fc.category_id  = c.category_id ;


select * 
from aktorzy_w_najczesciej_wypozyczanych_filmach_2
join (
		select fc.film_id 
	    ,	   c."name" 
	    from film_category fc
	    join category c  on fc.category_id  = c.category_id 
    ) kat 
     on kat.film_id = aktorzy_w_najczesciej_wypozyczanych_filmach_2.film_id ;



select * 
from aktorzy_w_najrzadziej_wypozyczanych_filmach_2
join (
		select fc.film_id 
	    ,	   c."name" 
	    from film_category fc
	    join category c  on fc.category_id  = c.category_id 
    ) kat 
     on kat.film_id = aktorzy_w_najrzadziej_wypozyczanych_filmach_2.film_id ;


 --- kwantyle 0.10 raz 0.90 --- 