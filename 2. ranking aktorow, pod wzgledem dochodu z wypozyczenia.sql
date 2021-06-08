----- 2.ranking aktorów, pod wzglêdem dochodu z wypo¿yczenia


--- b) wyliczamy ranking popularnosci aktorow pod wzgledem dochodu z wypozyczen
SELECT
  actor1.actor_id,
  actor1.first_name,
  actor1.last_name,
  SUM(tpc.amount) 									AS dochod_z_wypozyczen 
FROM tab_rental_clean trc
JOIN(
SELECT
  amount,rental_id
FROM tab_payment_clean) tpc 
  ON trc.rental_id = tpc.rental_id
JOIN tab_inventory_clean tic
  ON trc.inventory_id = tic.inventory_id
JOIN(
SELECT 
  actor_id,
  film_id
FROM film_actor) fa
  ON tic.film_id = fa.film_id 
JOIN(
SELECT
  actor_id,
  first_name,
  last_name FROM actor) actor1
  ON fa.actor_id = actor1.actor_id
GROUP BY 1,2,3
ORDER BY 4 DESC

--- wyliczamy w ilu filmach gral dany aktor
SELECT
  actor2.actor_id,
  COUNT(film_actor.film_id) 								AS ilosc_filmow
FROM film_actor 	
JOIN(
SELECT
  actor.actor_id
FROM actor) actor2
  ON film_actor.actor_id = actor2.actor_id 
GROUP BY 1

--- ³¹czymy powy¿sze dane w 1 zbiór 
create temp table tab1 AS
    SELECT
      actor3.actor_id,
      actor3.first_name,
      actor3.last_name, 
      SUM(tpc.amount) 								AS dochod_z_wypozyczen
    FROM tab_rental_clean trc
    JOIN(
    SELECT
      amount,
      rental_id
    FROM tab_payment_clean) tpc
      ON trc.rental_id = tpc.rental_id
    JOIN tab_inventory_clean tic
      ON trc.inventory_id = tic.inventory_id
    JOIN(
    SELECT
      actor_id,
      film_id
    FROM film_actor) fa
      ON tic.film_id = fa.film_id 
    JOIN(
    SELECT
      actor_id,
      first_name,
      last_name FROM actor) actor3
      ON fa.actor_id = actor3.actor_id
   GROUP BY 1,2,3

		
create temp table tab2 AS 
    SELECT
      actor4.actor_id,
      COUNT(fa.film_id)								AS ilosc_filmow 
    FROM film_actor fa 
    JOIN(
    SELECT
      actor_id 
    FROM actor) actor4
      ON fa.actor_id = actor4.actor_id 
   GROUP BY 1	
		
---- mamy wszystkie powyzsze dane w 1 zbiorze
SELECT
  tab1.*,
  tab2.ilosc_filmow,
  ROUND(tab1.dochod_z_wypozyczen/ilosc_filmow,2) 	AS dochod_na_film 
FROM tab1
JOIN tab2 
  ON tab1.actor_id = tab2.actor_id

---tworze tabele pomocnicza, gdzie mam dochodu per aktor i per film
create temp table tab3 AS
    SELECT 
      actor5.actor_id,
      actor5.first_name,
      actor5.last_name,
      fa.film_id,
      SUM(tpc.amount) 								AS dochod_z_wypozyczen
    FROM tab_rental_clean trc
	JOIN(
	SELECT
	  amount,rental_id
	FROM tab_payment_clean) tpc 
	  ON trc.rental_id = tpc.rental_id
    JOIN tab_inventory_clean tic
      ON trc.inventory_id = tic.inventory_id
    JOIN(
    SELECT
      actor_id,
      film_id 
    FROM film_actor) fa
      ON tic.film_id = fa.film_id 
    JOIN(
    SELECT
      actor_id,
      first_name,
      last_name
    FROM actor) actor5
      ON fa.actor_id = actor5.actor_id
   GROUP BY 1,2,3,4
    ORDER BY 1 DESC

-- wyliczam mediane dochodu z filmow dla danego aktora
create temp table tab4 AS
    SELECT DISTINCT 
      tab3.actor_id,
      tab3.first_name,
      tab3.last_name,
      tt.mediana  
    FROM tab3
    JOIN(
    SELECT
      actor_id ,
	  percentile_cont(0.5)  WITHIN GROUP(
	    ORDER BY dochod_z_wypozyczen DESC)			 AS mediana
	FROM tab3
	GROUP BY actor_id) tt 
	  ON tab3.actor_id = tt.actor_id
    ORDER BY 4 DESC

------- wszystkie dane zbiorczo w calosci
create temp table tabela_zbiorcza AS
    SELECT 
      tab1.*,
      tab2.ilosc_filmow,
      ROUND(tab1.dochod_z_wypozyczen/ilosc_filmow,2) AS dochod_na_film,
      t4.mediana
    FROM tab1
    JOIN tab2
      ON tab1.actor_id = tab2.actor_id 
    JOIN(
    SELECT
      tab4.actor_id,
      tab4.mediana 
    FROM tab4) t4
      ON tab1.actor_id = t4.actor_id

--- poszczegolne rankingi
---1) 10 najbardziej dochodowych aktor w calosci
SELECT *
FROM tab1
ORDER BY dochod_z_wypozyczen DESC
LIMIT 10

--2) 10 najbardziej dochodowych aktorow na jeden film
SELECT
  tab1.actor_id,
  tab1.first_name,
  tab1.last_name,
  ROUND(tab1.dochod_z_wypozyczen/ilosc_filmow,2)	 AS dochod_na_film
FROM tab1
JOIN tab2
  ON tab1.actor_id = tab2.actor_id
ORDER BY dochod_na_film DESC
LIMIT 10

---- 3) 10 najbardziej dochodowych aktorow pod wzgledem mediany dochodow z filmu
SELECT DISTINCT
  tab3.actor_id,
  tab3.first_name,
  tab3.last_name,
  tt.mediana
FROM tab3
JOIN(
SELECT
  actor_id,
  PERCENTILE_CONT(0.5)  WITHIN GROUP(
    ORDER BY dochod_z_wypozyczen DESC)				AS mediana
FROM tab3
GROUP BY actor_id) tt
  ON tab3.actor_id = tt.actor_id
ORDER BY 4 DESC
LIMIT 10

---- 4) ranking aktorow, pod wzgledem maksymalnego dochodu z danego filmu

SELECT 
  actor_id,
  first_name,
  last_name,
  MAX(dochod_z_wypozyczen)
FROM tab3
GROUP BY 1,2,3
ORDER BY 4 DESC
---### wnioski: nie istotna dana, bo tutaj konkretne filmy sa w czo³owce.

	

-----5) nadanie rankingu aktorów uwzglêdniaj¹c sumê ich rankingów z  3 miar, tj. dochodu ogolem, dochodu na film i mediany z filmow
---- (kazda ocena ma taka sam¹ wagê)
WITH ranking AS(

    SELECT
      actor_id,
      first_name,
      last_name,
      RANK() OVER(
        ORDER BY dochod_z_wypozyczen DESC)			AS rank_wg_dochodu,
      RANK() OVER(
        ORDER BY dochod_na_film DESC)				AS rank_wg_sredniego_dochodu,
      RANK() OVER(
        ORDER BY mediana DESC) 						AS rank_wg_mediany_dochodu
    FROM tabela_zbiorcza
    )
    
    SELECT *,
      rank_wg_dochodu + 
      rank_wg_sredniego_dochodu +
      rank_wg_mediany_dochodu 						AS ranking_ogolny
    FROM ranking
    ORDER BY 7
 