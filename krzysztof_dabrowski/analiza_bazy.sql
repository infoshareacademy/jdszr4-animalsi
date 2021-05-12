--- Badanie: tabela actor --- 
select * 
from actor; 

select * 
from actor a 
where a.first_name is null 
or a.last_name is null; 

--- wynik: nie ma wartosci pustych w first_name ani w last_name
--- klucze obce nie sa puste

-- Badanie: tabela address --- 

select * 
from address a ; 

select * 
from address a 
where a.address is null 
or a.address2 is null 
or a.district is null 
or a.postal_code is null 
or a.phone  is null; 

select * 
from address a 
where a.address is null 
or a.district is null 
or a.postal_code is null 
or a.phone  is null; 

select * 
from address a 
where a.city_id is null; 

--- Wynik: --- 
--- kolumna address2 zawsze pusta
--- w kolumnie postal_code czasami nulle , phone i distinct maja wbite chyba spacje
--- klucze obce  nie sa puste

--- Badanie: tabela category --- 

select * 
from category c ;


---  Wynik: mala tabela , wyglada dobrze
--- klucze obce  nie sa puste

--- Badanie: tabela city --- 

select * 
from city c ;

select * 
from city c 
where c.city is null
or c.city ~ '^ *$';

select * 
from city c 
where c.country_id is null; 

--- Wynik: Wyglada dobrze
--- kluczze obce  nie sa puste

--- Badanie: tabela country --- 

select * 
from country c ; 


select * 
from country c 
where c.country is null 
or c.country  ~ '^ *$';  

--- Wynik:  Wyglada dobrze
--- klucze obce  nie sa puste

--- Badanie: tabela customer --- 

select * 
from customer c ; 

select * 
from customer c 
where c.first_name is null 
or c.last_name  is null 
or c.email  is null 
or c.activebool is null 
or c.create_date  is null 
or c.active  is null; 

select * 
from customer c 
where c.email  not like '%@%';

select * 
from customer c 
where c.store_id is null 
or c.address_id  is null;

--- Wynik: Wyglada dobrze , emaile sa poprawne
--- klucze obce  nie sa puste

--- Badanie: tabela film ---

select * 
from film;  

select * 
from film f 
where f.title is null
or f.description is null 
or f.release_year  is null 
or f.rental_duration is null 
or f.rental_rate is null 
or f.length is null 
or f.replacement_cost is null 
or f.rating is null
or f.special_features is null;

select * 
from film f
where f.original_language_id is null; 


--- Wynik: klumna original_language_id jest zawsze nullem , reszta w porzadku 
--- klucze obce  nie sa puste

-- Badanie: tabela inventory ---

select * 
from inventory i ; 

select * 
from inventory i 
where i.film_id is null 
or i.store_id  is null; 

--- Wynik: wyglada ok  
--- klucze obce  nie sa puste
--- Badanie: tabela language ---

select * 
from "language" l ;

--- Wynik: wyglada ok 
--- klucze obce  nie sa puste

--- Badanie: tabela payment ---

select * 
from payment; 

select * 
from payment p 
where p.amount is null ;


select * 
from payment p 
where p.customer_id is null
or p.staff_id  is null 
or p.rental_id is null;


--- Wynik: Wyglada ok
--- klucze obce  nie sa puste

-- Badanie: tabela rental ---
select *
from rental; 

select * 
from rental r
where r.rental_date is null
or r.return_date is null; 

select * 
from rental r 
where r.inventory_id is null 
or r.customer_id is null 
or r.staff_id  is null;

--- Wynik: Sa takie rekordy ze kolumna return_date jest pusta , poza tym okej 
--- klucze obce  nie sa puste

-- Badanie: tabela staff ---

select *
from staff s ; 

--- Wynik: Kolumna picture pusta, reszta okej
--- klucze obce  nie sa puste

-- Badanie: tabela store ( tylko 2) ---

select * 
from store s; 

--- Wynik: Wyglada okej 
--- klucze obce  nie sa puste



--- pozostale informacje ---------

--- tabele payment_p2007_xxx --> puste tabele 