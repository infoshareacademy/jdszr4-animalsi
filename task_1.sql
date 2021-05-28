--analiza tabeli aktorow, mamy 200 pozycji
select * from actor a;

--sprawdzanie czy, ktorys z aktorow nie nazywa sie tak samo
--mamy 199 pozycji, czyli jest dwoch aktorow, ktorzy maja takie same dane - warto wiec brac numer id aktora
select distinct concat(a.first_name ,' ', a.last_name) from actor a ;

--analiza tabeli z filmami, mamy 1000 pozycji
select * from film f;

--mamy takze 1000 pozycji, zaden tytul nie zostal zdublowany
select distinct title from film f ;

--mamy 16044 pozycje w tabeli z wypozyczeniami, daty zwrotu sa czasem nullami
select * from rental r;

--mamy 16049 platnosci, czyli o 5 za duzo, dodatkowo w 24 przypadkach amount=0
select * from payment p;
--w przypadku platnosci gdzie rental_id =291 mamy 1 platnosc za duzo, dla rental_id=1 mamy 4 platnosci za duzo
select rental_id,
	count(rental_id)
from payment p 
group by rental_id
having count(rental_id)>1 ;

select * from payment p where rental_id =1 or rental_id =291;

--tworzenie tabeli do analizy: tabela zawierajaca aktorow, tytuly filmow oraz wypozyczenia
create temp table analiza_1_filmy
as
select a.actor_id,
	a.first_name,
	a.last_name,
	f.film_id,
	f.title,
	r.rental_id
from actor a 
join film_actor fa on a.actor_id = fa.actor_id 
join film f on fa.film_id =f.film_id 
join inventory i on f.film_id = i.film_id 
join rental r on i.inventory_id = r.inventory_id  --87980 wierszy
join payment p on r.rental_id = p.rental_id 
where r.rental_id!=1 and r.rental_id!=291 and r.return_date is not null and p.amount !=0;

select * from analiza_1_filmy;

--tworzenie tabeli drugiej do analizy: tabela zawierajaca aktorow oraz wypozyczenia
create temp table analiza_2_bez_filmow
as
select a.actor_id,
	a.first_name,
	a.last_name,
	r.rental_id
from actor a 
join film_actor fa on a.actor_id = fa.actor_id 
join film f on fa.film_id =f.film_id 
join inventory i on f.film_id = i.film_id 
join rental r on i.inventory_id = r.inventory_id  --87980 wierszy
join payment p on r.rental_id = p.rental_id 
where r.rental_id!=1 and r.rental_id!=291 and r.return_date is not null and p.amount !=0;

select * from analiza_2_bez_filmow;

--------RANKING AKTOROW I WIELKOSCI STATYSTYCZNE POD WZGLEDEM WYPOZYCZEN, UWZGLEDNIA TE SAME FILMY DLA DANEGO AKTORA, 
--------ALE WYPOZYCZONE PRZEZ ROZNE OSOBY (ZE WZGLEDY NA RENTAL_ID) 

-- w kazdym wypozyczeniu (rental_id), czyli wypozyczeniu filmu mamy takze kliku aktorow grajacych w tym filmie
create temp table aktor_ranking
as
select actor_id,
	first_name,
	last_name,
	count(rental_id) as ilosc_wypozyczen,
	dense_rank() over (order by count(rental_id) desc) as ranking_aktorow
from analiza_2_bez_filmow
group by actor_id, first_name, last_name
order by count(rental_id) desc;

--ranking aktorow
select * from aktor_ranking;

--ranking najlepszych 10 aktorow pod wzgledem ilosci wypozyczonych z nim filmow
select * from aktor_ranking where ranking_aktorow between 1 and 10;

--ranking najgorszych 10 aktorow pod wzgledem ilosci wypozyczonych z nim filmow
select * from aktor_ranking where ranking_aktorow between 141 and 150 order by ilosc_wypozyczen asc;

-- obliczam wielkosci statystyczne by porownac je z kazdym aktorem
select 
	avg(ilosc_wypozyczen) as srednia_ilosc_wypozyczen,
	min(ilosc_wypozyczen) as minimalna_ilosc_wypozyczen,
	max(ilosc_wypozyczen) as maksymalna_ilosc_wypozyczen,
	mode() within group (order by ilosc_wypozyczen) as moda,
	percentile_disc(0.5) within group (order by ilosc_wypozyczen) as mediana,
	percentile_disc(0.1) within group (order by ilosc_wypozyczen) as q10,
	percentile_disc(0.9) within group (order by ilosc_wypozyczen) as q90
from aktor_ranking;

--tabela pokazujaca, ktory aktor jest powyzej/ponizej sredniej ilosci wypozyczen
select * ,
	case when ilosc_wypozyczen > 434.8 then 'Aktor jest powyzej sredniej ilosc wypozyczen'
	when ilosc_wypozyczen = 434.8 then 'Aktor ma ilosc wypozyczen rowna sredniej ilosci wypozyczen'
	else 'Aktor jest ponizej sredniej wypozyczen' end as opis_rankingu
from aktor_ranking;

-----RANKIG FILMOW POD WZGLEDEM ILOSCI WYPOZYCZEN------
-----SPRAWDZENIE KTORE FILMY ZYSKALY NAJWIEKSZA POPULARNOSC-------

--Tworzenie tabeli, by sprawdzic ktore filmy sa najczesciej wypozyczane 
create temp table wypozyczane_filmy_ranking
as
select film_id,
	title,
	count(distinct rental_id) as ilosc_wypozyczen_danego_filmu,
	dense_rank() over (order by count(distinct rental_id) desc) as ranking_wypozyczanych_filmow
from analiza_1_filmy
group by film_id, title
order by count(distinct rental_id) desc;

--Ranking wypozyczanych filmow
select * from wypozyczane_filmy_ranking;

--16 najlepszych filmow pod wzgledem ilosci wypozyczen
select * from wypozyczane_filmy_ranking where ranking_wypozyczanych_filmow between 1 and 4;

--21 najgorszych filmow pod wzgledem ilosci wypozyczen
select * from wypozyczane_filmy_ranking where ranking_wypozyczanych_filmow between 30 and 31 order by ranking_wypozyczanych_filmow desc;

--wielkosci statystyczne by porownac je z kazdym filmem
select 
	round(avg(ilosc_wypozyczen_danego_filmu)::numeric, 1) as srednia_ilosc_wypozyczen_filmu,
	min(ilosc_wypozyczen_danego_filmu) as minimalna_ilosc_wypozyczen_filmu,
	max(ilosc_wypozyczen_danego_filmu) as maksymalna_ilosc_wypozyczen_filmu,
	mode() within group (order by ilosc_wypozyczen_danego_filmu) as moda,
	percentile_disc(0.5) within group (order by ilosc_wypozyczen_danego_filmu) as mediana,
	percentile_disc(0.1) within group (order by ilosc_wypozyczen_danego_filmu) as q10,
	percentile_disc(0.9) within group (order by ilosc_wypozyczen_danego_filmu) as q90
from wypozyczane_filmy_ranking;

--tabela pokazujaca ktory z filmow jak wypada na tle sredniej ilosci wypozczen

select *,
	case when ilosc_wypozyczen_danego_filmu > 16.6 then 'Film ma ilosc wypozczen powyzej sredniej'
	when ilosc_wypozyczen_danego_filmu = 16.6 then 'Film ma ilosc wypozczen rowna sredniej'
	else 'Film ma ilosc wypozczen ponizej sredniej' end as opis_rankingu
from wypozyczane_filmy_ranking;

-------RANKING AKTOROW POD WZGLEDEM ILOSCI WYPOZYCZEN W ROZBICIU NA ILOSC WYPOZCZEN KAZDEGO FILMU W KTORYM BRAL UDZIAL---------
create temp table ranking_aktorow_i_filmow
as
select actor_id,
	first_name,
	last_name,
	film_id,
	title,
	count (rental_id) as ilosc_wypozyczen_filmu_na_aktora,
	dense_rank() over (order by count (rental_id) desc) as miejsce_w_rankingu_wypozyczen_filmow
from analiza_1_filmy
group by actor_id, first_name, last_name, film_id, title;

--nieposortowany ranking aktorow oraz filmow
select * from ranking_aktorow_i_filmow;

--WAZNY RANKING! pokazuje ranking aktorow od tego ktory mial najwiecej wypozyczen w rozbiciu na ilosc wypozyczen konkretnego filmu
--w ktorym bral udzial, dane posortowane

--opis rankingu: przedstawione sa dane aktorow w kolejnosci od tego, ktory ma najwieksza ilosc wypozyczen, dalej przedstawione sa filmy
--w ktorych aktor gral. Kolumna ilosc_wypozyczen_filmu_na_aktora przedstawia ile razy dany film zostal wypozyczony, miejsce_w_rankingu_wypozyczen_filmow
--pokazuje pozycje filmu w rankingu wypozyczen, suma_wypozyczen aktora, to natomiast ilosc wypozyczen filmow z danym aktorem
select *,
	sum(ilosc_wypozyczen_filmu_na_aktora) over (partition by actor_id) as suma_wypozyczen_aktora
from ranking_aktorow_i_filmow
order by suma_wypozyczen_aktora desc;

--------ILOSC FILMOW W JAKICH AKTOR BRAL UDZIAL------
create temp table ilosc_filmow_na_aktora
as
select actor_id,
	first_name,
	last_name,
	count(distinct film_id) as ilosc_filmow_danego_aktora,
	dense_rank() over (order by count(distinct film_id) desc) as ranking_ilosci_filmow_na_aktora
from analiza_1_filmy
group by actor_id, first_name, last_name
order by count(distinct film_id) desc;

--wyznaczona ilosc filmow w jakiej gral dany aktor wraz z rankingiem
select * from ilosc_filmow_na_aktora;

--wielkosci statystyczne wyznaczone dla rankingu ilosci filmow w ktorych grali aktorzy
select 
	round(avg(ilosc_filmow_danego_aktora)::numeric, 1) as srednia_ilosc_filmow_aktorow,
	min(ilosc_filmow_danego_aktora) as minimalna_ilosc_filmow_aktora,
	max(ilosc_filmow_danego_aktora) as maksymalna_ilosc_filmow_aktora,
	mode() within group (order by ilosc_filmow_danego_aktora) as moda,
	percentile_disc(0.5) within group (order by ilosc_filmow_danego_aktora) as mediana,
	percentile_disc(0.1) within group (order by ilosc_filmow_danego_aktora) as q10,
	percentile_disc(0.9) within group (order by ilosc_filmow_danego_aktora) as q90
from ilosc_filmow_na_aktora;

select *,
	case when ilosc_filmow_danego_aktora > 26.2 then 'Aktor gral w liczbie filmow powyzej sredniej'
	when ilosc_filmow_danego_aktora = 26.2 then 'Aktor gral w liczbie filmow rownej sredniej '
	else 'Aktor gral w liczbie filmow ponizej sredniej' end as opis_rankingu
from ilosc_filmow_na_aktora;
