--SPRAWDZENIE CZY ILOŚĆ SZTUK NA MAGAZYNIE MA WPŁYW NA ILOŚĆ WYPOŻYCZEŃ AKTORA


SELECT * FROM inventory i;




--TWORZYMY TABELĘ TYMCZASOWĄ ZAWIERAJĄCĄ NIEZBĘDNE DO ANALIZY DANE I WYŁĄCZAJĄCĄ ANOMALIE


CREATE TEMP TABLE stan_magazynowy
AS
SELECT i.inventory_id,
	a.actor_id,
	a.first_name,
	a.last_name,
	f.film_id,
	f.title,
	r.rental_id
FROM actor a 
JOIN film_actor fa ON a.actor_id = fa.actor_id 
JOIN film f ON fa.film_id =f.film_id 
JOIN inventory i ON f.film_id = i.film_id 
JOIN rental r ON i.inventory_id = r.inventory_id  --87980 wierszy
JOIN payment p ON r.rental_id = p.rental_id 
WHERE r.rental_id!=1 AND r.rental_id!=291 AND r.return_date IS NOT NULL AND p.amount !=0;




--ZESTAWIENIE ILOŚCI SZTUK FILMÓW NA MAGAZYNIE, W KTÓRYCH GRAŁ DANY AKTOR WRAZ Z RANKINGIEM


SELECT actor_id,
	first_name,
	last_name,
	count(DISTINCT inventory_id) AS ilosc_sztuk_na_magazynie,
	dense_rank () OVER (ORDER BY count(DISTINCT inventory_id) DESC) AS ranking_sztuk_na_magazynie
FROM stan_magazynowy
GROUP BY actor_id, first_name, last_name
ORDER BY 4 DESC;




--ILOŚĆ WYPOŻCZEŃ DANEGO AKTORA, UWZGLEDNIA TE SAME FILMY ALE WYPOŻYCZONE PRZEZ RÓŻNE OSOBY


SELECT actor_id,
	first_name,
	last_name,
	count(rental_id) AS ilosc_wypozyczen,
	dense_rank() OVER (ORDER BY count(rental_id) DESC) AS ranking_aktorow
FROM stan_magazynowy
GROUP BY actor_id, first_name, last_name
ORDER BY count(rental_id) DESC;




--POŁĄCZENIE POWYŻYCH DWÓCH ZAPYTAŃ, ABY STWORZYĆ TABELKĘ Z ŁĄCZNYMI DANYMI DO WYZNACZENIA ZALEŻNOŚCI MIĘDZY ILOŚCIĄ SZTUK NA MAGAZYNIE, 
--A ILOŚCIĄ WYPOŻYCZEŃ DLA DANEGO AKTORA


CREATE TEMP TABLE dane_do_korelacji
AS
SELECT actor_id,
	first_name,
	last_name,
	count(DISTINCT inventory_id) AS ilosc_sztuk_na_magazynie,
	count(rental_id) AS ilosc_wypozyczen
FROM stan_magazynowy
GROUP BY actor_id, first_name, last_name
ORDER BY 5 DESC;




--WYZNACZENIE KORELACJI POMIĘDZY ILOŚCIĄ SZTUK FILMU NA MAGAZYNIE, W KTÓRYCH GRAŁ DANY AKTOR A ILOŚCIĄ WYPOŻYCZEŃ FILMÓW Z TYM AKTOREM
--WYZNACZENIE WSPÓŁCZYNNIKA KORELACJI


SELECT 
	round(corr(ilosc_sztuk_na_magazynie, ilosc_wypozyczen)::numeric,2) AS korelacja
FROM dane_do_korelacji;



