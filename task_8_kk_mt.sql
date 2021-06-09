--SPRAWDZENIE CZY ILOŚĆ SZTUK PŁYT NA MAGAZYNIE MA WPŁYW NA ILOŚĆ WYPOŻYCZEŃ AKTORA

SELECT * 
  FROM inventory AS i;

--TWORZYMY TABELĘ TYMCZASOWĄ ZAWIERAJĄCĄ NIEZBĘDNE DO ANALIZY DANE I WYŁĄCZAJĄCĄ ANOMALIE

CREATE TEMP TABLE stan_magazynowy
AS
 SELECT i.inventory_id, a.actor_id, f.film_id, r.rental_id,
        a.first_name, a.last_name, f.title
   FROM actor AS a 
        JOIN film_actor AS fa 
        ON a.actor_id = fa.actor_id 
        
        JOIN film AS f 
        ON fa.film_id =f.film_id 

        JOIN inventory AS i 
        ON f.film_id = i.film_id 
        
        JOIN rental AS r 
        ON i.inventory_id = r.inventory_id  --87980 wierszy

        JOIN payment AS p 
        ON r.rental_id = p.rental_id 
  WHERE r.rental_id!=1 
    AND r.rental_id!=291 
    AND r.return_date IS NOT NULL 
    AND p.amount !=0;

--ZESTAWIENIE ILOŚCI SZTUK FILMÓW NA MAGAZYNIE, W KTÓRYCH GRAŁ DANY AKTOR WRAZ Z RANKINGIEM

SELECT actor_id, first_name, last_name,
       COUNT(DISTINCT inventory_id) AS ilosc_sztuk_na_magazynie,
       DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT inventory_id) DESC) AS ranking_sztuk_na_magazynie
  FROM stan_magazynowy
 GROUP BY actor_id, first_name, last_name
 ORDER BY 4 DESC;

--ILOŚĆ WYPOŻCZEŃ DANEGO AKTORA, UWZGLEDNIA TE SAME FILMY ALE WYPOŻYCZONE PRZEZ RÓŻNE OSOBY

SELECT actor_id, first_name, last_name,
       COUNT(rental_id) AS ilosc_wypozyczen,
       DENSE_RANK() OVER (ORDER BY COUNT(rental_id) DESC) AS ranking_aktorow
  FROM stan_magazynowy
 GROUP BY actor_id, first_name, last_name
 ORDER BY COUNT(rental_id) DESC;

--POŁĄCZENIE POWYŻSZYCH DWÓCH ZAPYTAŃ, ABY STWORZYĆ TABELĘ Z ŁĄCZNYMI DANYMI DO WYZNACZENIA ZALEŻNOŚCI MIĘDZY ILOŚCIĄ SZTUK NA MAGAZYNIE, 
--A ILOŚCIĄ WYPOŻYCZEŃ DLA DANEGO AKTORA

CREATE TEMP TABLE dane_do_korelacji
AS
 SELECT actor_id, first_name, last_name,
        COUNT(DISTINCT inventory_id) AS ilosc_sztuk_na_magazynie,
        COUNT(rental_id) AS ilosc_wypozyczen
   FROM stan_magazynowy
  GROUP BY actor_id, first_name, last_name
  ORDER BY 5 DESC;

--WYZNACZENIE KORELACJI POMIĘDZY ILOŚCIĄ SZTUK FILMU NA MAGAZYNIE, W KTÓRYCH GRAŁ DANY AKTOR A ILOŚCIĄ WYPOŻYCZEŃ FILMÓW Z TYM AKTOREM
--WYZNACZENIE WSPÓŁCZYNNIKA KORELACJI

SELECT ROUND(CORR(ilosc_sztuk_na_magazynie, ilosc_wypozyczen)::NUMERIC,2) AS korelacja
  FROM dane_do_korelacji;



