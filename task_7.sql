--- obszar roboczy ---

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
	where r.return_date is not null
	group by 1
) zestawienie_wypozyczen


--- filmy wraz z aktorami ktore wpadaja w graniczne przedzialy pod katem liczby wypozyczen - kwantyle 0.25 oraz 0.75 ---
--------------------------------------------------------------------------------------------------------

--- kwantyl 0.25 -- aktorzy wraz z najmniej wypozyczanymi filmami , liczba wypozyczen mniejsza niz 25 % z wszystkich liczb wypozyczen filmow   ---

select i.film_id 
,	   count(*) as liczba_wypozyczen	
from rental r 
join inventory i on r.inventory_id = i.inventory_id 
where i.film_id != 257 and r.return_date is not null
group by 1
having count(*) <= ( 
		              select q_25
		              from analiza
		           )
order by 2 desc; 
		                


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
			where i.film_id != 257 and r.return_date is not null
			group by 1
			having count(*) <= ( 
		                     	 select q_25
		                      		from analiza
		                       )
		) filmy_najrzadsze 
)


--- aktorzy ktorzy wybiajaja sie na poczatek listy 

create temp table top_30_aktorow_najrzadziej_wypozyczane_filmy
as
select actor_id, 
       count(*) as liczba_filmow
from aktorzy_w_najrzadziej_wypozyczanych_filmach
group by 1 
order by 2 desc
limit 30;

--- histogram dla powyzszej tabelki bez limitu ( pomogl mi ustalic limit )

select distinct count(*) as liczba_filmow_per_aktor
       ,      count(*) over (partition by count(*)) as liczba_rekordow
from aktorzy_w_najrzadziej_wypozyczanych_filmach
group by actor_id 
order by 1 desc;


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
where i.film_id != 257 and r.return_date is not null
group by 1
having count(*) >= ( 
                        select q_75
                       from analiza 
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
			where i.film_id != 257 and r.return_date is not null
			group by 1
			having count(*) >= ( 
		                     	 select q_75
		                      		from analiza
		                       )
		) filmy_najczestsze
)



--- aktorzy ktorzy wyibiaja sie na poczatek listy 

create temp table top_30_aktorow_najczesciej_wypozyczane_filmy
as
select actor_id, 
	  count(*) as liczba_filmow
from aktorzy_w_najczesciej_wypozyczanych_filmach
group by 1 
order by 2 desc
limit 30;


--- histogram dla powyzszej tabelki bez limitu ( pomogl mi ustalic limit )

select distinct count(*) as liczba_filmow_per_aktor
       ,      count(*) over (partition by count(*)) as liczba_rekordow
from aktorzy_w_najczesciej_wypozyczanych_filmach
group by actor_id 
order by 1 desc;


select actor_id, 
       count(*) as liczba_filmow
from aktorzy_w_najczesciej_wypozyczanych_filmach
group by 1 
order by 1;

--- proba porownania danych pod katem wystepowania aktorow zarowno w filmach najmniej wypozyczanych jak i najbardziej wypozyczanych ---


select actor_id 
from top_30_aktorow_najrzadziej_wypozyczane_filmy

intersect

select actor_id 
from top_30_aktorow_najczesciej_wypozyczane_filmy;

--- Wyniki analizy: w czesci wspolnej mamy tylko 4 rekordy 65 , 82 , 198 i 107
--- Rezultat: Wynika z tego ze najrzadziej i najczeœciej wypozyczane filmy roznia sie znaczaco obsada aktorska . 
--- Idac dalej mozna powiedziec ze aktor ma wplyw na liczbe wypozyczen filmow  

select a2.first_name
,      a2.last_name
,      t30.liczba_filmow
from top_30_aktorow_najrzadziej_wypozyczane_filmy as t30
join actor a2 on t30.actor_id = a2.actor_id 
where t30.actor_id in (65,82,198,107)
order by 3 desc;

select a2.first_name
,      a2.last_name
,      t30.liczba_filmow
from top_30_aktorow_najczesciej_wypozyczane_filmy as t30
join actor a2 on t30.actor_id = a2.actor_id 
where t30.actor_id in (65,82,198,107)
order by 3 desc; 

--- Z powyzszeg wynika dodatkow ze aktorzy z czesci wspolnej czesto wystepuja w najrzadziej oraz najczesciej wypozyczanych filmach .
--- W zwiazku z tym ciezko wywniposkowac jak wplywaja na powuzsze wynkiki ale sa mala czescia z calosci wynikow


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
			where i.film_id != 257 and r.return_date is not null
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

--- histogram dla powyzszej tabelki bez limitu ( pomogl mi ustalic limit )

select distinct count(*) as liczba_filmow_per_aktor
       ,      count(*) over (partition by count(*)) as liczba_rekordow
from aktorzy_w_najrzadziej_wypozyczanych_filmach_2
group by actor_id 
order by 1 desc;



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
			where i.film_id != 257 and r.return_date is not null
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


---- histogram dla powyzszej tabelki bez limitu ( pomogl mi ustalic limit )

select distinct count(*) as liczba_filmow_per_aktor
       ,      count(*) over (partition by count(*)) as liczba_rekordow
from aktorzy_w_najczesciej_wypozyczanych_filmach_2
group by actor_id 
order by 1 desc;


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


--- Wyniki analizy: w czesci wspolnej mamy tylko 3 rekordy 65,198 i 107
--- Rezultat: Wynika z tego ze najrzadziej i najczeœciej wypozyczane filmy roznia sie znaczaco obsada aktorska . 
--- Idac dalej mozna powiedziec ze aktor ma wplyw na liczbe wypozyczen filmow  

select a2.first_name
,      a2.last_name
,      t20.liczba_filmow
from top_20_aktorow_najrzadziej_wypozyczane_filmy_2 as t20
join actor a2 on t20.actor_id = a2.actor_id 
where t20.actor_id in (65,198,107)
order by 3 desc; 

select a2.first_name
,      a2.last_name
,      t20.liczba_filmow
from top_20_aktorow_najczesciej_wypozyczane_filmy_2 as t20
join actor a2 on t20.actor_id = a2.actor_id 
where t20.actor_id in (65,198,107)
order by 3 desc; 

--- Z powyzszeg wynika dodatkow ze aktorzy z czesci wspolnej czesto wystepuja w najrzadziej oraz najczesciej wypozyczanych filmach .
--- W zwiazku z tym ciezko wywniposkowac jak wplywaja na powuzsze wynkiki ale sa mala czescia z calosci wynikow



--- analiza pozyzszych danych pod katem kategorii filmow w jakicjh wsytepowal aktor  ---
--- sprawdzamy w ilu kategoriach grali aktorzy w filamch najlepiej i najgorzej wyzpoyczanych ---  

--- kwantyle 0.25 oraz 0.75  

--- zestawienie aktorow grajacych w najczesciej wypozyczanych filmach wraz z ich kategoriami , kwantyl 0.75 ----- 

select a.actor_id
,      kat.name
,      kat.film_id
from aktorzy_w_najczesciej_wypozyczanych_filmach as a
join (
		select fc.film_id 
	    ,	   c."name" 
	    from film_category fc
	    join category c  on fc.category_id  = c.category_id 
    ) kat 
     on kat.film_id = a.film_id ;

select a.actor_id
,      count(kat.name) as ile_kategorii
from aktorzy_w_najczesciej_wypozyczanych_filmach as a
join (
		select fc.film_id 
		,	   c."name" 
		from film_category fc
		join category c  on fc.category_id  = c.category_id 
	) kat 
	     on kat.film_id = a.film_id 
group by 1
order by 2 desc;

-- histogram 

select distinct count(kat.name) as ile_lategorii_per_aktor 
,      count(*) over (partition by count(kat.name) )
from aktorzy_w_najczesciej_wypozyczanych_filmach as a
join (
		select fc.film_id 
	    ,	   c."name" 
	    from film_category fc
	    join category c  on fc.category_id  = c.category_id 
    ) kat 
     on kat.film_id = a.film_id 
group by a.actor_id
order by 2 desc;
   


--- statystki dotyczace powyzszego zestawinia 

select round(avg(ile_kategorii),2) as srednia_liczba_kategorii_per_aktor
,      percentile_cont(0.25) within group ( order by ile_kategorii ) as q_25
,	   percentile_cont(0.50) within group ( order by ile_kategorii) as mediana
,      percentile_cont(0.75) within group ( order by ile_kategorii ) as q_75
,      mode() within group ( order by ile_kategorii ) as moda
,      min(ile_kategorii) as minimalna_liczba_kategorii
,      max(ile_kategorii) as maksymalna_liczba_kategorii
from 
(
	select a.actor_id
	,      count(kat.name) as ile_kategorii
	from aktorzy_w_najczesciej_wypozyczanych_filmach as a
	join (
			select fc.film_id 
		    ,	   c."name" 
		    from film_category fc
		    join category c  on fc.category_id  = c.category_id 
	    ) kat 
	     on kat.film_id = a.film_id 
	group by 1
	order by 2 desc
) zest_ile_kategorii

--- Rezultat: Jak widac ze statystyk polowa aktoriw grala w co najmniej 8 filmach w adanej probie.
--- Pozwala to stwierdzic ze miara popularnosci filmow nie sa pojedynczy aktorzy a raczej wieksza czesc obsady   


--- zestawienie aktorow grajacych w narzadziej wypozyczanych filmach wraz z ich kategoriami , kwantyl 0.25 --------  

select * 
from aktorzy_w_najrzadziej_wypozyczanych_filmach as a
join (
		select fc.film_id 
	    ,	   c."name" 
	    from film_category fc
	    join category c  on fc.category_id  = c.category_id 
    ) kat 
     on kat.film_id = a.film_id ;

select a.actor_id
,      count(kat.name) as ile_kategorii
from aktorzy_w_najrzadziej_wypozyczanych_filmach as a
join (
		select fc.film_id 
		,	   c."name" 
		from film_category fc
		join category c  on fc.category_id  = c.category_id 
	) kat 
	     on kat.film_id = a.film_id 
group by 1
order by 2 desc;
    
       
--- histogram 

select distinct count(kat.name) as ile_lategorii_per_aktor 
,      count(*) over (partition by count(kat.name) )
from aktorzy_w_najrzadziej_wypozyczanych_filmach as a
join (
		select fc.film_id 
	    ,	   c."name" 
	    from film_category fc
	    join category c  on fc.category_id  = c.category_id 
    ) kat 
     on kat.film_id = a.film_id 
group by a.actor_id
order by 1 desc;
   

--- statystyki dotyczace powyzszego zestawienia 

select round(avg(ile_kategorii),2) as srednia_liczba_kategorii_per_aktor
,      percentile_cont(0.25) within group ( order by ile_kategorii ) as q_25
,	   percentile_cont(0.50) within group ( order by ile_kategorii) as mediana
,      percentile_cont(0.75) within group ( order by ile_kategorii ) as q_75
,      mode() within group ( order by ile_kategorii ) as moda
,      min(ile_kategorii) as minimalna_liczba_kategorii
,      max(ile_kategorii) as maksymalna_liczba_kategorii
from 
(
    select a.actor_id
	,      count(kat.name) as ile_kategorii 
	from aktorzy_w_najrzadziej_wypozyczanych_filmach as a
	join (
			select fc.film_id 
		    ,	   c."name" 
		    from film_category fc
		    join category c  on fc.category_id  = c.category_id 
	    ) kat 
	     on kat.film_id = a.film_id 
	group by 1
	order by 2 desc
) zest_ile_kategorii

--- Rezultat: Jak widac ze statystyk polowa aktoriw grala w co najmniej 8 filmach w badanej probie.
--- Pozwala to stwierdzic ze miara braku popularnosci filmow nie sa pojedynczy aktorzy a raczej wieksza czesc obsady   



 --- kwantyle 0.10 raz 0.90 --- 

--- zestawienie aktorow grajacych w najczesciej wypozyczanych filmach wraz z ich kategoriami , kwantyl 0.90 ----- 

select a2.actor_id
,      kat.name
,      kat.film_id
from aktorzy_w_najczesciej_wypozyczanych_filmach_2 as a2
join (
		select fc.film_id 
	    ,	   c."name" 
	    from film_category fc
	    join category c  on fc.category_id  = c.category_id 
    ) kat 
     on kat.film_id = a2.film_id ;

select a2.actor_id
,      count(kat.name) as ile_kategorii
from aktorzy_w_najczesciej_wypozyczanych_filmach_2 as a2
join (
		select fc.film_id 
		,	   c."name" 
		from film_category fc
		join category c  on fc.category_id  = c.category_id 
	) kat 
	     on kat.film_id = a2.film_id 
group by 1
order by 2 desc;

-- histogram 

select distinct count(kat.name) as ile_lategorii_per_aktor 
,      count(*) over (partition by count(kat.name) )
from aktorzy_w_najczesciej_wypozyczanych_filmach_2 as a2
join (
		select fc.film_id 
	    ,	   c."name" 
	    from film_category fc
	    join category c  on fc.category_id  = c.category_id 
    ) kat 
     on kat.film_id = a2.film_id 
group by a2.actor_id
order by 2 desc;
   


--- statystki dotyczace powyzszego zestawinia 

select round(avg(ile_kategorii),2) as srednia_liczba_kategorii_per_aktor
,      percentile_cont(0.25) within group ( order by ile_kategorii ) as q_25
,	   percentile_cont(0.50) within group ( order by ile_kategorii) as mediana
,      percentile_cont(0.75) within group ( order by ile_kategorii ) as q_75
,      mode() within group ( order by ile_kategorii ) as moda
,      min(ile_kategorii) as minimalna_liczba_kategorii
,      max(ile_kategorii) as maksymalna_liczba_kategorii
from 
(
	select a2.actor_id
	,      count(kat.name) as ile_kategorii
	from aktorzy_w_najczesciej_wypozyczanych_filmach_2 as a2
	join (
			select fc.film_id 
		    ,	   c."name" 
		    from film_category fc
		    join category c  on fc.category_id  = c.category_id 
	    ) kat 
	     on kat.film_id = a2.film_id 
	group by 1
	order by 2 desc
) zest_ile_kategorii

--- Rezultat: Jak widac ze statystyk polowa aktoriw grala w co najmniej 3 filmach w adanej probie.
--- Pozwala to stwierdzic ze miara popularnosci filmow nie sa pojedynczy aktorzy a raczej wieksza czesc obsady   
--- Ta proba odnosi sie do 10 % najczesciej wypozyczanych filmow a wiec zakres jest wezszy niz przy kwantylu 0,75 . 
---   Widac tutaj ze aktorzy graja w mniejszej ilosci kategorii a wiec aktorzy grajacy w najczescies wypozyczanych filmach sa skupienia na mniejszej liczbie kategrii filmow. 
  

--- zestawienie aktorow grajacych w narzadziej wypozyczanych filmach wraz z ich kategoriami , kwantyl 0.10 --------  

select * 
from aktorzy_w_najrzadziej_wypozyczanych_filmach_2
join (
		select fc.film_id 
	    ,	   c."name" 
	    from film_category fc
	    join category c  on fc.category_id  = c.category_id 
    ) kat 
     on kat.film_id = aktorzy_w_najrzadziej_wypozyczanych_filmach_2.film_id ;

select a2.actor_id
,      count(kat.name) as ile_kategorii
from aktorzy_w_najrzadziej_wypozyczanych_filmach_2 as a2
join (
		select fc.film_id 
		,	   c."name" 
		from film_category fc
		join category c  on fc.category_id  = c.category_id 
	) kat 
	     on kat.film_id = a2.film_id 
group by 1
order by 2 desc;
    
--- histogram 

select distinct count(kat.name) as ile_lategorii_per_aktor 
,      count(*) over (partition by count(kat.name) )
from aktorzy_w_najrzadziej_wypozyczanych_filmach_2 as a2
join (
		select fc.film_id 
	    ,	   c."name" 
	    from film_category fc
	    join category c  on fc.category_id  = c.category_id 
    ) kat 
     on kat.film_id = a2.film_id 
group by a2.actor_id
order by 1 desc;
   

--- statystyki dotyczace powyzszego zestawienia 

select round(avg(ile_kategorii),2) as srednia_liczba_kategorii_per_aktor
,      percentile_cont(0.25) within group ( order by ile_kategorii ) as q_25
,	   percentile_cont(0.50) within group ( order by ile_kategorii) as mediana
,      percentile_cont(0.75) within group ( order by ile_kategorii ) as q_75
,      mode() within group ( order by ile_kategorii ) as moda
,      min(ile_kategorii) as minimalna_liczba_kategorii
,      max(ile_kategorii) as maksymalna_liczba_kategorii
from 
(
    select a2.actor_id
	,      count(kat.name) as ile_kategorii 
	from aktorzy_w_najrzadziej_wypozyczanych_filmach_2 as a2
	join (
			select fc.film_id 
		    ,	   c."name" 
		    from film_category fc
		    join category c  on fc.category_id  = c.category_id 
	    ) kat 
	     on kat.film_id = a2.film_id 
	group by 1
	order by 2 desc
) zest_ile_kategorii


--- Rezultat: Jak widac ze statystyk polowa aktoriw grala w co najmniej 3 filmach w adanej probie.
--- Pozwala to stwierdzic ze miara popularnosci filmow nie sa pojedynczy aktorzy a raczej wieksza czesc obsady   
--- Ta proba odnosi sie do 10 % najrzadziej wypozyczanych filmow a wiec zakres jest wezszy niz przy kwantylu 0,25 . 
 ---   Widac tutaj ze aktorzy graja w mniejszej ilosci kategorii a wiec aktorzy grajacy w najrzadziejs wypozyczanych filmach sa skupieni na mniejszej liczbie kaegorii filmow. 

    