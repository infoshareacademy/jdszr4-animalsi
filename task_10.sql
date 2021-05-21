
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


