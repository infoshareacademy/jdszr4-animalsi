-- 0.WSTEPNA ANALIZA TABEL I STWORZENIE TABEL DO ANALIZY

--analiza tabeli aktorow, mamy 200 pozycji

SELECT * 
  FROM actor AS a;

--sprawdzanie czy, ktorys z aktorow nie nazywa sie tak samo
--mamy 199 pozycji, czyli jest dwoch aktorow, ktorzy maja takie same dane - warto wiec brac numer id aktora

SELECT DISTINCT concat(a.first_name ,' ', a.last_name) 
  FROM actor AS a;

--analiza tabeli z filmami, mamy 1000 pozycji
 
SELECT * 
  FROM film AS f;

--mamy takze 1000 pozycji, zaden tytul nie zostal zdublowany
 
SELECT DISTINCT title 
  FROM film AS f;

--mamy 16044 pozycje w tabeli z wypozyczeniami, daty zwrotu sa czasem nullami
 
SELECT * 
  FROM rental AS r;

--mamy 16049 platnosci, czyli o 5 za duzo, dodatkowo w 24 przypadkach amount=0
 
SELECT * 
  FROM payment AS p;

--w przypadku platnosci gdzie rental_id =291 mamy 1 platnosc za duzo, dla rental_id=1 mamy 4 platnosci za duzo
 
SELECT rental_id,
       COUNT(rental_id)
  FROM payment AS p 
 GROUP BY rental_id
HAVING COUNT(rental_id)>1;

SELECT * 
  FROM payment AS p 
 WHERE rental_id =1 
    OR rental_id =291;

--tworzenie tabeli do analizy: tabela zawierajaca aktorow, tytuly filmow oraz wypozyczenia
   
CREATE TEMP TABLE analiza_1_filmy
AS
 SELECT a.actor_id, f.film_id, r.rental_id,
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

SELECT *
  FROM analiza_1_filmy;

--tworzenie tabeli drugiej do analizy: tabela zawierajaca aktorow oraz wypozyczenia
 
CREATE TEMP TABLE analiza_2_bez_filmow
AS
 SELECT r.rental_id, a.actor_id,
        a.first_name, a.last_name
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

SELECT * 
  FROM analiza_2_bez_filmow;

-- 1.RANKING AKTOROW I WIELKOSCI STATYSTYCZNE POD WZGLEDEM WYPOZYCZEN, UWZGLEDNIA TE SAME FILMY DLA DANEGO AKTORA,ALE WYPOZYCZONE PRZEZ ROZNE OSOBY 

-- w kazdym wypozyczeniu (rental_id), czyli wypozyczeniu filmu mamy takze kliku aktorow grajacych w tym filmie
 
CREATE TEMP TABLE aktor_ranking
AS
 SELECT actor_id, first_name, last_name,
        COUNT(rental_id) AS ilosc_wypozyczen,
        DENSE_RANK() OVER (ORDER BY COUNT(rental_id) DESC) AS ranking_aktorow
   FROM analiza_2_bez_filmow
  GROUP BY actor_id, first_name, last_name
  ORDER BY COUNT(rental_id) DESC;

--ranking aktorow
 
SELECT * 
  FROM aktor_ranking;

--ranking najlepszych 10 aktorow pod wzgledem ilosci wypozyczonych z nim filmow
 
SELECT * 
  FROM aktor_ranking 
 WHERE ranking_aktorow BETWEEN 1 AND 10;

--ranking najgorszych 10 aktorow pod wzgledem ilosci wypozyczonych z nim filmow

SELECT * 
  FROM aktor_ranking 
 WHERE ranking_aktorow BETWEEN 141 AND 150 
 ORDER BY ilosc_wypozyczen ASC;

-- obliczam wielkosci statystyczne by porownac je z kazdym aktorem

SELECT AVG(ilosc_wypozyczen) AS srednia_ilosc_wypozyczen,
       MIN(ilosc_wypozyczen) AS minimalna_ilosc_wypozyczen,
       MAX(ilosc_wypozyczen) AS maksymalna_ilosc_wypozyczen,
       MODE() WITHIN GROUP (ORDER BY ilosc_wypozyczen) AS moda,
       PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY ilosc_wypozyczen) AS mediana,
       PERCENTILE_DISC(0.1) WITHIN GROUP (ORDER BY ilosc_wypozyczen) AS q10,
       PERCENTILE_DISC(0.9) WITHIN GROUP (ORDER BY ilosc_wypozyczen) AS q90
  FROM aktor_ranking;

--tabela pokazujaca, ktory aktor jest powyzej/ponizej sredniej ilosci wypozyczen
 
SELECT *,
       CASE 
       WHEN ilosc_wypozyczen > 434.8 THEN 'Aktor jest powyzej sredniej ilosc wypozyczen'
       WHEN ilosc_wypozyczen = 434.8 THEN 'Aktor ma ilosc wypozyczen rowna sredniej ilosci wypozyczen'
       ELSE 'Aktor jest ponizej sredniej wypozyczen' 
       END AS opis_rankingu
  FROM aktor_ranking;

-- 2.RANKIG FILMOW POD WZGLEDEM ILOSCI WYPOZYCZEN, SPRAWDZENIE KTORE FILMY ZYSKALY NAJWIEKSZA POPULARNOSC

--Tworzenie tabeli, by sprawdzic ktore filmy sa najczesciej wypozyczane 
 
CREATE TEMP TABLE wypozyczane_filmy_ranking
AS
 SELECT film_id, title,
        COUNT(DISTINCT rental_id) AS ilosc_wypozyczen_danego_filmu,
        DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT rental_id) DESC) AS ranking_wypozyczanych_filmow
   FROM analiza_1_filmy
  GROUP BY film_id, title
  ORDER BY COUNT(DISTINCT rental_id) DESC;

--Ranking wypozyczanych filmow
 
SELECT * 
  FROM wypozyczane_filmy_ranking;

--16 najlepszych filmow pod wzgledem ilosci wypozyczen
 
SELECT * 
  FROM wypozyczane_filmy_ranking 
 WHERE ranking_wypozyczanych_filmow BETWEEN 1 AND 4;

--21 najgorszych filmow pod wzgledem ilosci wypozyczen

SELECT * 
  FROM wypozyczane_filmy_ranking 
 WHERE ranking_wypozyczanych_filmow BETWEEN 30 AND 31 
 ORDER BY ranking_wypozyczanych_filmow DESC;

--wielkosci statystyczne by porownac je z kazdym filmem

SELECT ROUND(AVG(ilosc_wypozyczen_danego_filmu)::NUMERIC, 1) AS srednia_ilosc_wypozyczen_filmu,
       MIN(ilosc_wypozyczen_danego_filmu) AS minimalna_ilosc_wypozyczen_filmu,
       MAX(ilosc_wypozyczen_danego_filmu) AS maksymalna_ilosc_wypozyczen_filmu,
       MODE() WITHIN GROUP (ORDER BY ilosc_wypozyczen_danego_filmu) AS moda,
       PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY ilosc_wypozyczen_danego_filmu) AS mediana,
       PERCENTILE_DISC(0.1) WITHIN GROUP (ORDER BY ilosc_wypozyczen_danego_filmu) AS q10,
       PERCENTILE_DISC(0.9) WITHIN GROUP (ORDER BY ilosc_wypozyczen_danego_filmu) AS q90
  FROM wypozyczane_filmy_ranking;

--tabela pokazujaca ktory z filmow jak wypada na tle sredniej ilosci wypozczen

SELECT *,
       CASE  
       WHEN ilosc_wypozyczen_danego_filmu > 16.6 THEN 'Film ma ilosc wypozczen powyzej sredniej'
       WHEN ilosc_wypozyczen_danego_filmu = 16.6 THEN 'Film ma ilosc wypozczen rowna sredniej'
       ELSE 'Film ma ilosc wypozczen ponizej sredniej' 
       END AS opis_rankingu
  FROM wypozyczane_filmy_ranking;

-- 3.RANKING AKTOROW POD WZGLEDEM ILOSCI WYPOZYCZEN W ROZBICIU NA ILOSC WYPOZCZEN KAZDEGO FILMU W KTORYM BRAL UDZIAL
 
CREATE TEMP TABLE ranking_aktorow_i_filmow
AS
 SELECT actor_id, film_id,
        first_name, last_name, title,
        COUNT (rental_id) AS ilosc_wypozyczen_filmu_na_aktora,
        DENSE_RANK() OVER (ORDER BY COUNT (rental_id) DESC) AS miejsce_w_rankingu_wypozyczen_filmow
   FROM analiza_1_filmy
  GROUP BY actor_id, first_name, last_name, film_id, title;

--nieposortowany ranking aktorow oraz filmow
 
SELECT * 
  FROM ranking_aktorow_i_filmow;

--WAZNY RANKING: pokazuje ranking aktorow od tego ktory mial najwiecej wypozyczen w rozbiciu na ilosc wypozyczen konkretnego filmu, 
--w ktorym bral udzial, dane posortowane

--opis rankingu: przedstawione sa dane aktorow w kolejnosci od tego, ktory ma najwieksza ilosc wypozyczen, dalej przedstawione sa filmy
--w ktorych aktor gral. Kolumna ilosc_wypozyczen_filmu_na_aktora przedstawia ile razy dany film zostal wypozyczony, miejsce_w_rankingu_wypozyczen_filmow
--pokazuje pozycje filmu w rankingu wypozyczen, suma_wypozyczen aktora, to natomiast ilosc wypozyczen filmow z danym aktorem
 
SELECT *,
       SUM(ilosc_wypozyczen_filmu_na_aktora) OVER (PARTITION BY actor_id) AS suma_wypozyczen_aktora
  FROM ranking_aktorow_i_filmow
 ORDER BY suma_wypozyczen_aktora DESC, miejsce_w_rankingu_wypozyczen_filmow ASC;

--4. ILOSC FILMOW W JAKICH AKTOR BRAL UDZIAL

CREATE TEMP TABLE ilosc_filmow_na_aktora
AS
 SELECT actor_id, first_name, last_name,
        COUNT(DISTINCT film_id) AS ilosc_filmow_danego_aktora,
        DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT film_id) DESC) AS ranking_ilosci_filmow_na_aktora
   FROM analiza_1_filmy
  GROUP BY actor_id, first_name, last_name
  ORDER BY COUNT(DISTINCT film_id) DESC;

--wyznaczona ilosc filmow w jakiej gral dany aktor wraz z rankingiem
 
SELECT * 
  FROM ilosc_filmow_na_aktora;

--wielkosci statystyczne wyznaczone dla rankingu ilosci filmow w ktorych grali aktorzy
 
SELECT ROUND(AVG(ilosc_filmow_danego_aktora)::NUMERIC, 1) AS srednia_ilosc_filmow_aktorow,
       MIN(ilosc_filmow_danego_aktora) AS minimalna_ilosc_filmow_aktora,
       MAX(ilosc_filmow_danego_aktora) AS maksymalna_ilosc_filmow_aktora,
       MODE() WITHIN GROUP (ORDER BY ilosc_filmow_danego_aktora) AS moda,
       PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY ilosc_filmow_danego_aktora) AS mediana,
       PERCENTILE_DISC(0.1) WITHIN GROUP (ORDER BY ilosc_filmow_danego_aktora) AS q10,
       PERCENTILE_DISC(0.9) WITHIN GROUP (ORDER BY ilosc_filmow_danego_aktora) AS q90
  FROM ilosc_filmow_na_aktora;

SELECT *,
       CASE 
       WHEN ilosc_filmow_danego_aktora > 26.2 THEN 'Aktor gral w liczbie filmow powyzej sredniej'
       WHEN ilosc_filmow_danego_aktora = 26.2 THEN 'Aktor gral w liczbie filmow rownej sredniej '
       ELSE 'Aktor gral w liczbie filmow ponizej sredniej' 
       END AS opis_rankingu
  FROM ilosc_filmow_na_aktora;
 
-- 5. SPRAWDZENIE CZY ILOSC WYPOZYCZEN AKTORA ZALEZY OD ILOSCI FILMOW W KTORYCH GRAŁ, ZBADANIE KORELACJI

--stworzenie i wyswietlenie tabeli przechowujacej ilosc wypozyczen danego aktora oraz ilosc filmow w ktorych gral
 
CREATE TEMP TABLE srednia_wypozyczen_per_film 
AS
 SELECT actor_id, first_name, last_name,
        COUNT(rental_id) AS ilosc_wypozyczonych_filmow,
        COUNT(DISTINCT film_id) AS ilosc_filmow_aktora,
        ROUND(COUNT(rental_id)/COUNT(DISTINCT film_id)::NUMERIC,1) AS srednia_wypozyczen_na_film
   FROM analiza_1_filmy
  GROUP BY actor_id, first_name, last_name
  ORDER BY COUNT(rental_id) DESC;

SELECT *
  FROM srednia_wypozyczen_per_film;

--wyznaczenie korelacji miedzy iloscia wypozyczen aktora a iloscia jego filmow
 
SELECT ROUND(CORR(ilosc_wypozyczonych_filmow, ilosc_filmow_aktora)::NUMERIC,2) AS korelacja 
  FROM srednia_wypozyczen_per_film;
