# Sklep DVD - Czy aktor ma wp�yw na popularno�� filmu i doch�d z wypo�ycze�

##### autorzy grupa: jdszr4-animalsi 

## Cel projektu

------------------------------------------------------------------------

Celem projektu by�o zbadanie czy poszczeg�lni aktorzy maj� wp�yw na popularno�� film�w, w kt�rych grali oraz doch�d z ich wypo�ycze�.

## Metodologia

------------------------------------------------------------------------

W projekcie wykorzystano baz� danych Sakila. Analizy zosta�y przeprowadzone w j�zyku SQL, korzystaj�c z programu DBeaver na silniku PostgreSQL.

## Dane wy��czone z analizy

------------------------------------------------------------------------

-   w tabeli Payment znalaz�y si� nadmiarowe p�atno�ci w przeliczeniu na jedno wypo�yczenie: wypo�yczenia o id=1 (5 transakcji) i id=291 (2 transakcje),
-   w tabeli Film, filmy o ID 257, 323 i 803 nie by�o przypisanych �adnych aktor�w,
-   w tabeli Rental, by�y 182 przypadki bez daty zwrotu (1,1% wszystkich),
-   w tabeli Payment, znalaz�o si� 24 transakcje z op�at� za wypo�ycze� wynosz�c� 0 (0,15%)

## Kr�tka charakterystyka danych

------------------------------------------------------------------------

Baza danych przedstawia dane za lata 2005 - 2006, zawiera 958 film�w, w kt�rych gra�o 200 r�nych aktor�w. Ka�dy aktor gra� w minimum 14 r�nych filmach. W danych znalaz�o si� oko�o 16 tys. wypo�ycze�.

## Cz�ciowy schemat bazy, ERD

------------------------------------------------------------------------

Korzystaj�c z bazy danych Sakila, jedynie cz�� bazy danych zosta�a wykorzystana w projekcie gdy� pozosta�e tabele nie mia�y wp�ywu na rozwi�zanie problemu projektu.

Uproszczony schemat wykorzystanej cz�ci bazy Sakila przedstawiony zosta� na rysunku obok

![struktura bazy](C:/Users/Dawid/Desktop/kurs/jdszr4-animalsi/obrazki/struktura_danych.png)

## Analiza danych

### 1. Ranking aktor�w, pod wzgl�dem ilo�� wypo�ycze�

------------------------------------------------------------------------

*Task_1*

Analiza wypo�ycze� aktor�w, popularno�ci tytu��w film�w, zbiorcze zestawienie i ranking wypo�ycze� aktor�w w podziale na konkretne tytu�y filmu, wyznaczenie ilo�ci film�w ka�dego aktora oraz �redniej wypo�ycze� przypadaj�c� na jeden film aktora.

### 2. Ranking aktor�w, pod wzgl�dem dochodu z wypo�ycze�

------------------------------------------------------------------------

*Task_2*

Ranking aktor�w wed�ug, ca�kowitego dochodu, �redniego dochodu na film, mediany dochodu z wypo�ycze�, sumy rang w pozosta�ych rankingach

### 5. Ranking aktor�w, pod wzgl�dem czasu wypo�yczenia

------------------------------------------------------------------------

*Task_5*

Ranking na podstawie wsp�czynnika d�ugo�ci wypo�yczenia film�w danego aktora w stosunku do maksymalnego dost�pnego czasu na wypo�yczenia ich film�w.

### 6. Ranking (�rednia cena wypo�yczonych film�w)

------------------------------------------------------------------------

*Task_6*

Analiza ceny wypo�yczenia filmu. Sprawdzenie czy aktorzy maj� wp�yw na dzienn� cen� wypo�yczenia filmu. Ustalenie na podstawie skrajnych warto�ci jacy aktorzy grali w filmach. Analiza ceny wypo�yczenia filmu. Analiza ilo�ci wypo�ycze� dla ka�dego filmu (wraz z cenami za wypo�yczenie tych film�w).

### 7. Ranking r�norodno�ci aktor�w i kategorii

------------------------------------------------------------------------

*Task_7*

**Dane wej�ciowe:** 25 % najcz�ciej i najrzadziej wypo�yczonych film�w 10 % najcz�ciej i najrzadziej wypo�yczonych film�w

**Co zostalo zrobione:** - Zbadanie ilo�ci film�w w jakich grali aktorzy wraz ze statytsykami - Zbadanie ilo�ci kategorii film�w w kt�rzy grali aktorzy wraz ze statystykami - Sprawdzenie czy aktorzy graj�cy w najwi�kszej liczbie film�w s� tacy sami w 10% najcz�ciej oraz 10% najrzadziej wypo�yczonych filmach? - Sprawdzenie zzy aktorzy graj�cy w najwi�kszej liczbie film�w s� tacy sami w 25% najcz�ciej oraz 25% najrzadziej wypo�yczonych filmach?

### 8. Ranking wypo�ycze� film�w ze wzgl�du na ich dost�pno�� w wypo�yczalni

------------------------------------------------------------------------

*Task_8*

Wyznaczenie zale�no�ci mi�dzy stanem magazynowym film�w a ilo�ci� ich wypo�ycze�. Analiza �redniej wypo�ycze� wzgl�dem zapasu film�w w wypo�yczalni.

## Podsumowanie

-   Brak istotnego wp�ywu aktora na liczb� wypo�ycze�, mierz�c �redni� liczb� wypo�ycze� per film na aktora.
-   Aktorzy maj� wp�yw na doch�d z wypo�ycze�. (Wysoki doch�d generowali nast�puj�cy aktorzy: K. Paltrow, N. Degeneres, G. Heston, T. Miranda).
-   Aktor nie ma wp�ywu na ca�kowity czas wypo�yczenia filmu w kt�rym gra�.
-   Bez wzgl�du na miejsca w rankingu aktor�w grali oni zar�wno w tych bardziej jak i tych mniej popularnych filmach.
-   Aktor nie ma wp�ywu na wypo�yczenia filmu ze wzgl�du na cen� jego wypo�yczenia.
-   Nie odnotowano zale�no�ci pomi�dzy aktorem, a konkretn� kategori� filmu. (Ka�dy z aktor�w wyst�powa� w przynajmniej jednym filmie z konkretnej kategorii).
-   Analizuj�c �redni� liczb� wypo�ycze� z danym aktorem na stan magazynowy trudno stwierdzi� przy posiadanych danych ze wzgl�du na niewielkie odchylenie wok� warto�ci �redniej czy dany aktor wp�ywa na popularno�� film�w, w kt�rych gra.
