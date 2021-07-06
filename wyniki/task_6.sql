
--- Cz�� 1. Analiza ceny wypo�yczenia filmu. Czy aktorzy maj� wp�yw na dzienn� cen� wypo�yczenia filmu ? ---


--- W tym zadaniam spawdzam jaki jest rozstrzal cen wypozyczen filmow 
--- Na bazie tego biore skrajne wartosci i sprawdzam jacy aktorzy grali w filamch 
--- w oparciu o te wartosci. 
--- Nastepnie sprawdzam czesci wspolne zbiorow zeby sprobowac odpwiedziec na postawione pytanie

--- Kazdy nowy blok kodu zaczyna sie od komentarzaa w nastepujacej postaci "--- KOMENTARZ ---" 


--- sprawdzam ile mamy uniklanych dziennych cen wypozyczen filmow  --- 

SELECT * 
  FROM rental;

SELECT  DISTINCT f.rental_rate 
  FROM film f; 

SELECT f.rental_rate,      
       count(*)
  FROM film f
 GROUP BY 1;


 --- Sprawdzam jaka ilosc filmow przypada na dana cene wypozyczenia
 
SELECT *
  FROM film f
 WHERE f.rental_rate = 0.99; 

SELECT *
  FROM film f
 WHERE f.rental_rate = 2.99; 

SELECT * 
  FROM film f 
 WHERE f.rental_rate = 4.99;
 
--- Rezultat: Mamy 3 ceny, liczba filmow rozlozona jest w miare rownomiernie rozlozona


--- Szukamy aktorow ktorzy graja w filamch o cenie dziennej 0.99 ---
--- Wazne sa id aktorow ktore pobieramy z tablei film_actor ---

CREATE TEMP TABLE aktorzy_mala_cena_dzienna AS
    SELECT fa.actor_id,      
           fa.film_id 
      FROM film_actor fa 
     WHERE fa.film_id IN (		
                          SELECT f.film_id 
                            FROM film f
                           WHERE f.rental_rate = 0.99  
                         );
                       

--- Pogrupowanie aktorow wraz z iloscia filmow w jakich grali w oparciu o powyzsze dane                    

SELECT  adc.actor_id,       
        count(*) AS liczba_flimow
  FROM aktorzy_mala_cena_dzienna adc
 GROUP BY 1 
 ORDER BY 2 DESC;  --- 200 aktor�w

 
--- Szukamy aktorow ktorzy graja w filmach o cenie dziennej 4.99 ---
--- Wazne sa id aktorow ktore pobieramy z tablei film_actor ---

 CREATE TEMP TABLE aktorzy_duza_cena_dzienna AS
    SELECT * 
      FROM film_actor fa 
    WHERE fa.film_id IN (		
                          SELECT f.film_id 
                            FROM film f
                           WHERE f.rental_rate = 4.99  
                        ); 


--- Pogrupowanie aktorow wraz z iloscia filmow w jakich grali w oparciu o powyzsze dane         
			
SELECT  adc.actor_id,       
        count(*) AS liczba_flimow
  FROM aktorzy_duza_cena_dzienna adc
 GROUP BY 1 
 ORDER BY 2 DESC; --- 200 aktor�w 

 
--- Szukamy aktorow ktorzy graja w filmach o cenie dziennej 2.99 ---
--- Wazne sa id aktorow ktore pobieramy z tablei film_actor ---

CREATE TEMP TABLE aktorzy_srednia_cena_dzienna AS
    SELECT * 
      FROM film_actor fa 
     WHERE fa.film_id IN (
                           SELECT f.film_id 
                             FROM film f
                            WHERE f.rental_rate = 2.99  
                         ); 


--- Pogrupowanie aktorow wraz z iloscia filmow w jakich grali w oparciu o powyzsze dane   
			
SELECT  aksc.actor_id,       
        count(*) as liczba_flimow
  FROM aktorzy_srednia_cena_dzienna aksc
 GROUP BY 1 
 ORDER BY 2 DESC; --- 200 aktor�w

SELECT count(*) 
  FROM actor a; --- 200 aktorow w bazie


--- Proba porowanania zbiorow id aktorow ktore sa stworzone w 3 powyszych czesciach ( cena filmu 0.99,2.99,4.99 ) ---

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
  FROM aktorzy_srednia_cena_dzienna --- cena 2.99

INTERSECT

SELECT  actor_id
  FROM aktorzy_duza_cena_dzienna   --- cena 4.99

--- Wynik : 200 aktorow co jest rowne ogolnej ilosci aktorow 
--- Wnika z tego ze aktor nie ma zbyt duzego wplywu na duza i mala  ceny wypozycen filmow 

  
--- Cz�� 2. Analiza ceny wypo�yczenia filmu. W jakiej cenie najcz�ciej wypo�yczamy filmy ? ---

  
/*�acz� dwie tabelki: rental oraz payment.
  Usuwam rekordy zawieraj�ce anomalie: film id = 257(poniewa� nie zawiera on przypisanych aktor�w, 
  rekordy, gdzie amount = 0 oraz te kt�rych rental_id ma wiecej ni� jedn� p�atno�� (payment_id). */

CREATE TEMP TABLE t1_wypozyczenia AS
SELECT 		r.rental_id, 
			r.inventory_id 
FROM rental AS r 
LEFT JOIN payment p ON r.rental_id = p.rental_id 
WHERE p.amount > 0 
 	AND r.return_date IS NOT NULL
 	AND r.rental_id NOT IN (1, 291, 66, 1767, 6788, 7304, 12172, 8519, 12663, 2672, 5794, 8503, 14315) ; 

SELECT count(*) FROM t1_wypozyczenia;				-- 15 848 wierszy


/*��cz� wcze�niej utworzon� tabelk� t1_wypozyczenia z tabel� inventory 
  w celu uzyskania id wypo�yczanych film�w. */
	
CREATE TEMP TABLE t2_wypozyczenia_filmy AS
SELECT 		t1.rental_id,
			i.film_id 
FROM t1_wypozyczenia t1
LEFT JOIN inventory i ON t1.inventory_id = i.inventory_id 
ORDER BY 1;

SELECT count(*) FROM t2_wypozyczenia_filmy;				-- 15 848 wierszy


/*��cz� wcze�niej utworzon� tabelk� t2_wypozyczenia_filmy z tabel� film 
  w celu uzyskania pe�nych tytu��w wypo�yczanych film�w.
  oraz cen za ich wypo�yczenie. */

CREATE TEMP TABLE t3_wypozyczenia_filmy_ceny AS
SELECT 		t2.*,
			f.title,
			f.rental_rate 
FROM t2_wypozyczenia_filmy t2
LEFT JOIN film f ON t2.film_id = f.film_id ;

SELECT count (*) FROM t3_wypozyczenia_filmy_ceny;		  -- 15 848 wierszy


/*��cz� wcze�niej utworzon� tabelk� t3_wypozyczenia_filmy_ceny z tabel� film_actor 
  w celu uzyskania id aktor�w graj�cych w analizowanych filmach. */

CREATE TEMP TABLE t4_wypozyczenia_filmy_ceny_aktorzy AS
SELECT 		t3.*, 
			fa.actor_id 
FROM t3_wypozyczenia_filmy_ceny t3 
LEFT JOIN film_actor fa ON t3.film_id = fa.film_id ;

SELECT count(*) FROM t4_wypozyczenia_filmy_ceny_aktorzy; 	 -- 86 989 wiersze(w jednym filmie mo�e gra� wiele aktor�w 


/*Sprawdzam ilo�� wypo�ycze� dla ka�dego filmu (wraz z cenami za wypo�yczenie tych film�w). */

CREATE TEMP TABLE t5_film_cena_ilosc_wypozyczen AS
SELECT  	film_id
			rental_rate,
 			count(film_id) AS ilosc_wypozyczen
FROM t3_wypozyczenia_filmy_ceny 
GROUP BY 1,2
ORDER BY 3 DESC;


/* Uzyskane wcze�niej wyniki grupuj� po trzech otrzymanych cenach ( 0.99, 2.99 oraz 4.99). */ 

SELECT  rental_rate,
		sum (ilosc_wypozyczen) AS wypozyczenia
FROM t5_film_cena_ilosc_wypozyczen
GROUP BY 1
ORDER BY 2 DESC;

/* SPOSTRZE�ENIA: Najwiecej wypo�ycze� odnotowano dla film�w po cenie 0.99 za wypo�yczenie.
  Jednak�e ilo�ci wypo�yczen film�w po 2.99 i 4.99 s� nieznacznie ni�sze.
  Otrzymane wyniki s� bardzo porownywalne. */ 


/* Obliczam wsp�czynnik korealcji pomi�dzy cen� za wypo�yczenie filmu, 
 * a ilo�ci� jego wypozycze� w celu zbadania zale�no�ci 
 * pomi�dzy dwiem tymi zmiennymi. */ 

SELECT round (corr ( rental_rate, ilosc_wypozyczen)::numeric,2) AS korelacja 
FROM t5_film_cena_ilosc_wypozyczen;  

/*SPOSTRZE�ENIA: Lekko ujemna (-0.05 ) korelacja, �wiadcz�ca o niejakim braku zale�no�ci 
 * pomi�dzy cen� za wypo�yczenie filmu, a ilo�ci� jego wypo�ycze�. */

