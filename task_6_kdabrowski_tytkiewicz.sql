
--- Czêœæ 1. Analiza ceny wypo¿yczenia filmu. Czy aktorzy maj¹ wp³yw na dzienn¹ cenê wypo¿yczenia filmu ? ---


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
 ORDER BY 2 DESC;  --- 200 aktorów

 
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
 ORDER BY 2 DESC; --- 200 aktorów 

 
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
 ORDER BY 2 DESC; --- 200 aktorów

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

  
--- Czêœæ 2. Analiza ceny wypo¿yczenia filmu. W jakiej cenie najczêœciej wypo¿yczamy filmy ? ---

  
/*£aczê dwie tabelki: rental oraz payment.
  Usuwam rekordy zawieraj¹ce anomalie: film id = 257(poniewa¿ nie zawiera on przypisanych aktorów, 
  rekordy, gdzie amount = 0 oraz te których rental_id ma wiecej ni¿ jedn¹ p³atnoœæ (payment_id). */

CREATE TEMP TABLE t1_wypozyczenia AS
SELECT 		r.rental_id, 
			r.inventory_id 
FROM rental AS r 
LEFT JOIN payment p ON r.rental_id = p.rental_id 
WHERE p.amount > 0 
 	AND r.return_date IS NOT NULL
 	AND r.rental_id NOT IN (1, 291, 66, 1767, 6788, 7304, 12172, 8519, 12663, 2672, 5794, 8503, 14315) ; 

SELECT count(*) FROM t1_wypozyczenia;				-- 15 848 wierszy


/*£¹czê wczeœniej utworzon¹ tabelkê t1_wypozyczenia z tabel¹ inventory 
  w celu uzyskania id wypo¿yczanych filmów. */
	
CREATE TEMP TABLE t2_wypozyczenia_filmy AS
SELECT 		t1.rental_id,
			i.film_id 
FROM t1_wypozyczenia t1
LEFT JOIN inventory i ON t1.inventory_id = i.inventory_id 
ORDER BY 1;

SELECT count(*) FROM t2_wypozyczenia_filmy;				-- 15 848 wierszy


/*£¹czê wczeœniej utworzon¹ tabelkê t2_wypozyczenia_filmy z tabel¹ film 
  w celu uzyskania pe³nych tytu³ów wypo¿yczanych filmów.
  oraz cen za ich wypo¿yczenie. */

CREATE TEMP TABLE t3_wypozyczenia_filmy_ceny AS
SELECT 		t2.*,
			f.title,
			f.rental_rate 
FROM t2_wypozyczenia_filmy t2
LEFT JOIN film f ON t2.film_id = f.film_id ;

SELECT count (*) FROM t3_wypozyczenia_filmy_ceny;		  -- 15 848 wierszy


/*£¹czê wczeœniej utworzon¹ tabelkê t3_wypozyczenia_filmy_ceny z tabel¹ film_actor 
  w celu uzyskania id aktorów graj¹cych w analizowanych filmach. */

CREATE TEMP TABLE t4_wypozyczenia_filmy_ceny_aktorzy AS
SELECT 		t3.*, 
			fa.actor_id 
FROM t3_wypozyczenia_filmy_ceny t3 
LEFT JOIN film_actor fa ON t3.film_id = fa.film_id ;

SELECT count(*) FROM t4_wypozyczenia_filmy_ceny_aktorzy; 	 -- 86 989 wiersze(w jednym filmie mo¿e graæ wiele aktorów 


/*Sprawdzam iloœæ wypo¿yczeñ dla ka¿dego filmu (wraz z cenami za wypo¿yczenie tych filmów). */

CREATE TEMP TABLE t5_film_cena_ilosc_wypozyczen AS
SELECT  	film_id
			rental_rate,
 			count(film_id) AS ilosc_wypozyczen
FROM t3_wypozyczenia_filmy_ceny 
GROUP BY 1,2
ORDER BY 3 DESC;


/* Uzyskane wczeœniej wyniki grupujê po trzech otrzymanych cenach ( 0.99, 2.99 oraz 4.99). */ 

SELECT  rental_rate,
		sum (ilosc_wypozyczen) AS wypozyczenia
FROM t5_film_cena_ilosc_wypozyczen
GROUP BY 1
ORDER BY 2 DESC;

/* SPOSTRZE¯ENIA: Najwiecej wypo¿yczeñ odnotowano dla filmów po cenie 0.99 za wypo¿yczenie.
  Jednak¿e iloœci wypo¿yczen filmów po 2.99 i 4.99 s¹ nieznacznie ni¿sze.
  Otrzymane wyniki s¹ bardzo porownywalne. */ 


/* Obliczam wspó³czynnik korealcji pomiêdzy cen¹ za wypo¿yczenie filmu, 
 * a iloœci¹ jego wypozyczeñ w celu zbadania zale¿noœci 
 * pomiêdzy dwiem tymi zmiennymi. */ 

SELECT round (corr ( rental_rate, ilosc_wypozyczen)::numeric,2) AS korelacja 
FROM t5_film_cena_ilosc_wypozyczen;  

/*SPOSTRZE¯ENIA: Lekko ujemna (-0.05 ) korelacja, œwiadcz¹ca o niejakim braku zale¿noœci 
 * pomiêdzy cen¹ za wypo¿yczenie filmu, a iloœci¹ jego wypo¿yczeñ. */

