
select count(*) 
from rental r ; --- 16 044

-- film id 257 

select * 
from rental r ; 



select count(*)

select * 
from payment p 
where p.amount = 0;


--- tabela ktora podsumowuje nam ilosc wypozyczen filmu per jego id 

select i.film_id 
,	   count(*) as liczba_wypozyczen	
from rental r 
join inventory i on r.inventory_id = i.inventory_id 
group by 1
order by 2; --- daje nam to 958 pozycji 


--- tabela w ktorej przechowujemy dane statystyczne dotyczace powyzszej tabeli 

drop table analiza;
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


--- filmy ktore wpadaja w graniczne przedzialy pod katem liczby wypozyczen  

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
order by 2 desc; 

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
order by 2 desc; 

select i.film_id 
,	   count(*) as liczba_wypozyczen	
from rental r 
join inventory i on r.inventory_id = i.inventory_id 
where i.film_id != 257
group by 1
having count(*) >= (
                      ( 
                        select q_90
                       from analiza 
                      )
)
order by 2 desc; 


--- analiza pod katem kategorii i aktorow 




select i.film_id 
,	r.rental_id 	
from rental r 
join inventory i on r.inventory_id = i.inventory_id 
where i.film_id = 686;

