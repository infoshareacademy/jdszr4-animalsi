--- Analiza ceny wypozyczenia filmu . Czy aktorzy maja wplyw na dzienna cene wypozyczenia ? 

--- W tym zadaniam spawdzam jaki jest rozstrzal cen wypozyczen filmow 
--- Na bazie tego biore skrajne wartosci i sprawdzam jacy aktorzy grali w filamch 
--- w oparciu o te wartosci 

--- Nastepnie sprawdzam czesci wspolne zbiorow zeby sprobowac odpwiedziec na postawione pytanie


--- sprawdzam ile mamy uniklanych dziennych cen wypozyczen filmow  --- 

SELECT  DISTINCT f.rental_rate 
 FROM film f; 

SELECT f.rental_rate,      
       count(*)
  FROM film f
 GROUP BY 1;

--- Rezultat: Mamy 3 ceny, liczba filmow rozlozona jest w miare rownomiernie rozlozona

SELECT *
  FROM film f
 WHERE f.rental_rate = 0.99 ; 

SELECT * 
  FROM film f 
 WHERE f.rental_rate = 4.99;

--- Szukamy aktorow ktorzy graja w filamch o cenie dziennej 0.99 

CREATE TEMP TABLE aktorzy_mala_cena_dzienna
AS
	SELECT fa.actor_id,      
		   fa.film_id 
	  FROM film_actor fa 
	 WHERE fa.film_id IN (		
							SELECT f.film_id 
							  FROM film f
							 WHERE f.rental_rate = 0.99  
						);

SELECT  adc.actor_id,       
		count(*) AS liczba_flimow
  FROM aktorzy_mala_cena_dzienna adc
 GROUP BY 1 
 ORDER BY 2 DESC;

--- Szukamy aktorow ktorzy graja w filmach o cenie dziennej 4.99

CREATE TEMP TABLE aktorzy_duza_cena_dzienna
AS
	SELECT * 
	  FROM film_actor fa 
	 WHERE fa.film_id IN (
		
							SELECT f.film_id 
							  FROM film f
							 WHERE f.rental_rate = 4.99  
						 ); 

SELECT  adc.actor_id,       
        count(*) AS liczba_flimow
  FROM aktorzy_duza_cena_dzienna adc
 GROUP BY 1 
 ORDER BY 2 DESC;


CREATE TEMP TABLE aktorzy_srednia_cena_dzienna
AS
	SELECT * 
	  FROM film_actor fa 
	 WHERE fa.film_id IN (
							SELECT f.film_id 
							  FROM film f
							 WHERE f.rental_rate = 2.99  
						 ); 

SELECT  aksc.actor_id,       
        count(*) as liczba_flimow
  FROM aktorzy_srednia_cena_dzienna aksc
 GROUP BY 1 
 ORDER BY 2 DESC;

SELECT count(*) 
  FROM actor a; --- 200 aktorow w bazie

--- Proba porowanania zbiorow 

SELECT  actor_id
  FROM aktorzy_mala_cena_dzienna --- cena: 0.99

INTERSECT

SELECT  actor_id
  FROM aktorzy_duza_cena_dzienna --- cena 4.99

--- Wynik : 200 aktorow co jest rowne ogolnej ilosci aktorow 
--- Wnika z tego ze aktor nie ma zbyt duzego wplywu na skrajne dzienne ceny wypozycen filmow 

SELECT  actor_id
  FROM aktorzy_mala_cena_dzienna --- cena 0.99

INTERSECT 

SELECT  actor_id
  FROM aktorzy_srednia_cena_dzienna --- cena 2.99

--- Wynik : 200 aktorow co jest rowne ogolnej ilosci aktorow 
--- Wnika z tego ze aktor nie ma zbyt duzego wplywu na srednia i mala cene wypozyczen filmow 


SELECT  actor_id
from aktorzy_srednia_cena_dzienna --- cena 2.99

INTERSECT

SELECT  actor_id
FROM aktorzy_duza_cena_dzienna   --- cena 4.99

--- Wynik : 200 aktorow co jest rowne ogolnej ilosci aktorow 
--- Wnika z tego ze aktor nie ma zbyt duzego wplywu na duza i mala  ceny wypozycen filmow 
