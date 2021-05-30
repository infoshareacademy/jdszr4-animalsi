-- 5. ranking per film (czas wypozyczen)
--ile czasu dany aktor by³ wypo¿yczony.


-- I przy zalozeniu, ze wszystkie filmy byly od poczatku
--a) najpier ile maksymalnie jeden film moglbyc czasu wypozyczony, tj. data_ostatnia - data_pierwsza

CREATE TEMP TABLE max_czas AS
	SELECT
	  DATE_PART('day',
	    MAX(return_date) -
	    MIN(rental_date))*24*60 +
	  DATE_PART('hours',
	    MAX(return_date) -
	    MIN(rental_date)) *60 	+
	  DATE_PART('minutes',
	    MAX(return_date) -
	    MIN(rental_date)) 		AS max_dostepnosc
	FROM tab_rental_clean 
	WHERE return_date is not null

--b) potem ile dany inventory_id byl wypozyczony w stosunku do tego czasu,
-- usuwamy filmy, ktore nie zostaly zwrocone

SELECT
  inventory_id,
  SUM(DATE_PART('day',return_date- rental_date) * 1440 +
  DATE_PART('hours',return_date- rental_date) * 60 +
  DATE_PART('minutes',return_date- rental_date)) AS dl_wypozyczenia
 FROM tab_rental_clean
 WHERE return_date IS NOT NULL
 GROUP BY 1
 ORDER BY 2 DESC
 
-- po³aczenie obu zapytan w jedno//
-- ile procent czasu dany ID by³ wypo¿yczony
CREATE TEMP TABLE wsp_wypozyczen_I AS
	WITH czas AS(
	
		SELECT
		  DATE_PART('day',
		    MAX(return_date) -
		    MIN(rental_date))*24*60 +
		  DATE_PART('hours',
		    MAX(return_date) -
		    MIN(rental_date)) *60 	+
		  DATE_PART('minutes',
		    MAX(return_date) -
		    MIN(rental_date)) 		AS max_dostepnosc
		FROM tab_rental_clean 
		WHERE return_date IS NOT NULL
	
	), tabela AS(
	
		SELECT
		  inventory_id,
		  SUM(DATE_PART('day',return_date- rental_date) * 1440 +
		  DATE_PART('hours',return_date- rental_date) * 60 +
		  DATE_PART('minutes',return_date- rental_date)) AS dl_wypozyczenia
		 FROM tab_rental_clean
		 WHERE return_date IS NOT NULL
		 GROUP BY 1
		 ORDER BY 2 DESC
		 
	)
	
	    SELECT
	      inventory_id,
	      max_dostepnosc,
	      dl_wypozyczenia,
	      ROUND((dl_wypozyczenia/max_dostepnosc)::numeric,2) AS wsk_wypozyczenia
	    FROM tabela
	    CROSS JOIN czas
	    ORDER BY 2 DESC

SELECT *
FROM wsp_wypozyczen_I
	    
 --c) ile dany aktor w ramach swoich filmow byl wypozyczany

CREATE TEMP TABLE tab_dl_wypozyczen_per_actor_I AS
  SELECT
  	wsp1.inventory_id,
  	wsp1.dl_wypozyczenia,
  	wsp1.max_dostepnosc,
  	wsp1.wsk_wypozyczenia,
  	a.actor_id,
  	a.first_name,
  	a.last_name 
  FROM wsp_wypozyczen_I	AS wsp1
  JOIN inventory			AS i 
  	ON wsp1.inventory_id = i.inventory_id 
  JOIN film_actor 			AS fa 
  	ON i.film_id = fa.film_id 
  JOIN actor 				AS a
  	ON fa.actor_id = a.actor_id 
 
SELECT actor_id, first_name, last_name,
  round((sum(dl_wypozyczenia)/sum(max_dostepnosc))::NUMERIC,3) AS wsk_wypozyczenia_per_actor
FROM tab_dl_wypozyczen_per_actor_I tdwpa1
GROUP BY 1,2,3
ORDER BY 4 DESC   
    
    
-- II przy zalozeniu, ze dany film byl od momentu jego pierwszego wypozyczenia
--a) calosciowe zestawienie inventory_id, wraz z jego wsk_wypozyczenia
-- odlitrowalem te filmy, ktore moglybyc wypozyczone krocej niz 10 dni.
-- Czyli czas od pierwszego wypozyczenia do ostatniej daty jest nizszy niz 14400 minut

CREATE TEMP TABLE wsp_wypozyczen_II AS
	WITH czas_V1		AS(
	
		SELECT
		inventory_id,
		  DATE_PART('day',
		    MAX(return_date) -
		    MIN(rental_date))*24*60 +
		  DATE_PART('hours',
		    MAX(return_date) -
		    MIN(rental_date)) *60 	+
		  DATE_PART('minutes',
		    MAX(return_date) -
		    MIN(rental_date))	AS max_dostepnosc
		FROM tab_rental_clean
		WHERE return_date IS NOT NULL
		GROUP BY 1
		
	), czasy_zbiorcze	AS(
	
		SELECT *
		FROM czas_v1
		WHERE max_dostepnosc >14400
		
	), tabela 			AS(
	
		SELECT
		  inventory_id,
		  SUM(DATE_PART('day',return_date- rental_date) * 1440 +
		  DATE_PART('hours',return_date- rental_date) * 60 +
		  DATE_PART('minutes',return_date- rental_date)) AS dl_wypozyczenia
		 FROM tab_rental_clean
		 WHERE return_date IS NOT NULL
		 GROUP BY 1
		 ORDER BY 2 DESC 
	)	
	
		SELECT 
		  czasy_zbiorcze.inventory_id,
		  czasy_zbiorcze.max_dostepnosc,
		  tabela.dl_wypozyczenia,
		  round((dl_wypozyczenia/max_dostepnosc)::NUMERIC,2) AS wsk_wypozyczenia
		FROM czasy_zbiorcze
		LEFT JOIN tabela 
			ON czasy_zbiorcze.inventory_id = tabela.inventory_id
		ORDER BY 4 DESC
		
SELECT *
FROM wsp_wypozyczen_II

--c) ile dany aktor w ramach swoich filmow byl wypozyczany

CREATE TEMP TABLE tab_dl_wypozyczen_per_actor_II AS
  SELECT
  	wsp.inventory_id,
  	wsp.dl_wypozyczenia,
  	wsp.max_dostepnosc,
  	wsp.wsk_wypozyczenia,
  	a.actor_id,
  	a.first_name,
  	a.last_name 
  FROM wsp_wypozyczen_II	AS wsp
  JOIN inventory			AS i 
  	ON wsp.inventory_id = i.inventory_id 
  JOIN film_actor 			AS fa 
  	ON i.film_id = fa.film_id 
  JOIN actor 				AS a
  	ON fa.actor_id = a.actor_id 
 
SELECT actor_id, first_name, last_name,
  round((sum(dl_wypozyczenia)/sum(max_dostepnosc))::NUMERIC,3) AS wsk_wypozyczenia_per_actor
FROM tab_dl_wypozyczen_per_actor_II AS tdwpa2
GROUP BY 1,2,3
ORDER BY 4 DESC


 