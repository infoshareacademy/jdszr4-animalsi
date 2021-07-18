-- czyszczenie danych, ktore zostaly uznane jako anomalia

CREATE TABLE tab_rental_clean AS
    SELECT 
      rental_id,
      rental_date,
      inventory_id,
      customer_id,
      return_date 
    FROM rental r2 
    WHERE rental_id  NOT IN (1,291) 

CREATE TABLE tab_payment_clean as
    SELECT 
      p.payment_id,
      rental_id,
      amount,
      payment_date 
    FROM payment p 
    WHERE amount >0 
      AND rental_id  NOT IN (1,291)


CREATE TABLE tab_inventory_clean AS
    SELECT
      inventory_id, 
      film_id
    FROM inventory i 
    WHERE i.film_id <> 257
