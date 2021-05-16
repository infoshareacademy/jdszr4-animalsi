----- 2.ranking aktorów, pod wzglêdem dochodu z wypo¿yczenia

--a) czyscimy dane, ktore zostaly uznane jako anomalia

create table tab_rental_clean as
select rental_id, rental_date, inventory_id , customer_id , return_date from rental r2 
where rental_id  not in (1,291) 

create table tab_payment_clean as
select p.payment_id, rental_id, amount, payment_date from payment p 
where amount >0 and rental_id  not in (1,291)


create table tab_inventory_clean as
select inventory_id , film_id from inventory i 
where i.film_id <> 257

--- b) wyliczamy ranking popularnosci aktorow pod wzgledem dochodu z wypozyczen
select a.actor_id, a.first_name, a.last_name, sum(tpc.amount) dochod_z_wypozyczen from tab_rental_clean trc
join (select amount,rental_id from tab_payment_clean ) tpc on trc.rental_id = tpc.rental_id
join tab_inventory_clean tic on trc.inventory_id = tic.inventory_id
join (select actor_id, film_id from film_actor  ) fa on tic.film_id = fa.film_id 
join (select actor_id, first_name, last_name from actor)a on fa.actor_id = a.actor_id
group by 1,2,3
order by 4 desc

--- wyliczamy w ilu filmach gral dany aktor

select a1.actor_id, count(fa1.film_id) as ilosc_filmow from film_actor fa1 
join (select aa.actor_id from actor aa) a1 on fa1.actor_id = a1.actor_id 
group by 1

--- ³¹czymy powy¿sze dane w 1 zbiór 
create temp table tab1 as
select a.actor_id, a.first_name, a.last_name, sum(tpc.amount) dochod_z_wypozyczen from tab_rental_clean trc
join (select amount,rental_id from tab_payment_clean ) tpc on trc.rental_id = tpc.rental_id
join tab_inventory_clean tic on trc.inventory_id = tic.inventory_id
join (select actor_id, film_id from film_actor  ) fa on tic.film_id = fa.film_id 
join (select actor_id, first_name, last_name from actor)a on fa.actor_id = a.actor_id
group by 1,2,3

		
create temp table tab2 as 
select a1.actor_id, count(fa1.film_id) as ilosc_filmow from film_actor fa1 
		join (select aa.actor_id from actor aa) a1 on fa1.actor_id = a1.actor_id 
		group by 1	
		
---- mamy wszystkie powyzsze dane w 1 zbiorze
select tab1.*,  tab2.ilosc_filmow,  round(tab1.dochod_z_wypozyczen/ilosc_filmow,2) as dochod_na_film from tab1
join tab2 on tab1.actor_id = tab2.actor_id

---tworze tabele pomocnicza, gdzie mam dochodu per aktor i per film
create temp table tab3 as
select a.actor_id, a.first_name, a.last_name, fa.film_id, sum(tpc.amount) dochod_z_wypozyczen
from tab_rental_clean trc
join (select amount,rental_id from tab_payment_clean ) tpc on trc.rental_id = tpc.rental_id
join tab_inventory_clean tic on trc.inventory_id = tic.inventory_id
join (select actor_id, film_id from film_actor  ) fa on tic.film_id = fa.film_id 
join (select actor_id, first_name, last_name from actor)a on fa.actor_id = a.actor_id
group by 1,2,3,4
order by 1 desc

-- wyliczam mediane dochodu z filmow dla danego aktora
create temp table tab4 as
select distinct tab3.actor_id, tab3.first_name, tab3.last_name, tt.mediana  from tab3
join (select actor_id ,
	percentile_cont(0.5)  within group (order by dochod_z_wypozyczen desc) mediana
	from tab3
	group by actor_id) tt on tab3.actor_id = tt.actor_id
order by 4 desc

------- wszystkie dane zbiorczo w calosci
create temp table tabela_zbiorcza as
select tab1.*,  tab2.ilosc_filmow,  round(tab1.dochod_z_wypozyczen/ilosc_filmow,2) as dochod_na_film, t4.mediana from tab1
join tab2 on tab1.actor_id = tab2.actor_id 
join (select tab4.actor_id, tab4.mediana from tab4) t4 on tab1.actor_id = t4.actor_id

--- poszczegolne rankingi
---1) 10 najbardziej dochodowych aktor w calosci
select * from tab1
order by dochod_z_wypozyczen desc
limit 10

--2) 10 najbardziej dochodowych aktorow na jeden film
select tab1.actor_id, tab1.first_name, tab1.last_name,   round(tab1.dochod_z_wypozyczen/ilosc_filmow,2) as dochod_na_film from tab1
join tab2 on tab1.actor_id = tab2.actor_id
order by dochod_na_film desc
limit 10

---- 3) 10 najbardziej dochodowych aktorow pod wzgledem mediany dochodow z filmu
select distinct tab3.actor_id, tab3.first_name, tab3.last_name, tt.mediana  from tab3
join (select actor_id ,
	percentile_cont(0.5)  within group (order by dochod_z_wypozyczen desc) mediana
	from tab3
	group by actor_id) tt on tab3.actor_id = tt.actor_id
order by 4 desc
limit 10

---- 4) ranking aktorow, pod wzgledem maksymalnego dochodu z danego filmu

select actor_id, first_name, last_name, max(dochod_z_wypozyczen)
	from tab3
	group by 1,2,3
	order by 4 desc
---### wnioski: nie istotna dana, bo tutaj konkretne filmy sa w czo³owce.

	

-----5) nadanie rankingu aktorów uwzglêdniaj¹c sumê ich rankingów z  3 miar, tj. dochodu ogolem, dochodu na film i mediany z filmow
---- (kazda ocena ma taka sam¹ wagê)
select actor_id, first_name, last_name,
rank() over ( order by dochod_z_wypozyczen desc) + 
rank() over (order by dochod_na_film desc) +
rank () over (order by mediana desc) ranking  from tabela_zbiorcza
order by 4 

