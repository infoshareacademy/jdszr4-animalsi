-- czyszczenie danych, ktore zostaly uznane jako anomalia

create table tab_rental_clean as
    select 
      rental_id,
      rental_date,
      inventory_id,
      customer_id,
      return_date 
    from rental r2 
    where rental_id  not in (1,291) 

create table tab_payment_clean as
    select 
      p.payment_id,
      rental_id,
      amount,
      payment_date 
    from payment p 
    where amount >0 
      and rental_id  not in (1,291)


create table tab_inventory_clean as
    select
      inventory_id, 
      film_id
    from inventory i 
    where i.film_id <> 257
