# Sklep DVD - Czy aktor ma wp³yw na popularnoœæ filmu i dochód z wypo¿yczeñ

##### autorzy grupa: jdszr4-animalsi 

## Cel projektu

------------------------------------------------------------------------

Celem projektu by³o zbadanie czy poszczególni aktorzy maj¹ wp³yw na popularnoœæ filmów, w których grali oraz dochód z ich wypo¿yczeñ.

## Metodologia

------------------------------------------------------------------------

W projekcie wykorzystano bazê danych Sakila. Analizy zosta³y przeprowadzone w jêzyku SQL, korzystaj¹c z programu DBeaver na silniku PostgreSQL.

## Dane wy³¹czone z analizy

------------------------------------------------------------------------

-   w tabeli Payment znalaz³y siê nadmiarowe p³atnoœci w przeliczeniu na jedno wypo¿yczenie: wypo¿yczenia o id=1 (5 transakcji) i id=291 (2 transakcje),
-   w tabeli Film, filmy o ID 257, 323 i 803 nie by³o przypisanych ¿adnych aktorów,
-   w tabeli Rental, by³y 182 przypadki bez daty zwrotu (1,1% wszystkich),
-   w tabeli Payment, znalaz³o siê 24 transakcje z op³at¹ za wypo¿yczeñ wynosz¹c¹ 0 (0,15%)

## Krótka charakterystyka danych

------------------------------------------------------------------------

Baza danych przedstawia dane za lata 2005 - 2006, zawiera 958 filmów, w których gra³o 200 ró¿nych aktorów. Ka¿dy aktor gra³ w minimum 14 ró¿nych filmach. W danych znalaz³o siê oko³o 16 tys. wypo¿yczeñ.

## Czêœciowy schemat bazy, ERD

------------------------------------------------------------------------

Korzystaj¹c z bazy danych Sakila, jedynie czêœæ bazy danych zosta³a wykorzystana w projekcie gdy¿ pozosta³e tabele nie mia³y wp³ywu na rozwi¹zanie problemu projektu.

Uproszczony schemat wykorzystanej czêœci bazy Sakila przedstawiony zosta³ na rysunku obok

![struktura bazy](C:/Users/Dawid/Desktop/kurs/jdszr4-animalsi/obrazki/struktura_danych.png)

## Analiza danych

### 1. Ranking aktorów, pod wzglêdem iloœæ wypo¿yczeñ

------------------------------------------------------------------------

*Task_1*

Analiza wypo¿yczeñ aktorów, popularnoœci tytu³ów filmów, zbiorcze zestawienie i ranking wypo¿yczeñ aktorów w podziale na konkretne tytu³y filmu, wyznaczenie iloœci filmów ka¿dego aktora oraz œredniej wypo¿yczeñ przypadaj¹c¹ na jeden film aktora.

### 2. Ranking aktorów, pod wzglêdem dochodu z wypo¿yczeñ

------------------------------------------------------------------------

*Task_2*

Ranking aktorów wed³ug, ca³kowitego dochodu, œredniego dochodu na film, mediany dochodu z wypo¿yczeñ, sumy rang w pozosta³ych rankingach

### 5. Ranking aktorów, pod wzglêdem czasu wypo¿yczenia

------------------------------------------------------------------------

*Task_5*

Ranking na podstawie wspó³czynnika d³ugoœci wypo¿yczenia filmów danego aktora w stosunku do maksymalnego dostêpnego czasu na wypo¿yczenia ich filmów.

### 6. Ranking (œrednia cena wypo¿yczonych filmów)

------------------------------------------------------------------------

*Task_6*

Analiza ceny wypo¿yczenia filmu. Sprawdzenie czy aktorzy maj¹ wp³yw na dzienn¹ cenê wypo¿yczenia filmu. Ustalenie na podstawie skrajnych wartoœci jacy aktorzy grali w filmach. Analiza ceny wypo¿yczenia filmu. Analiza iloœci wypo¿yczeñ dla ka¿dego filmu (wraz z cenami za wypo¿yczenie tych filmów).

### 7. Ranking ró¿norodnoœci aktorów i kategorii

------------------------------------------------------------------------

*Task_7*

**Dane wejœciowe:** 25 % najczêœciej i najrzadziej wypo¿yczonych filmów 10 % najczêœciej i najrzadziej wypo¿yczonych filmów

**Co zostalo zrobione:** - Zbadanie iloœci filmów w jakich grali aktorzy wraz ze statytsykami - Zbadanie iloœci kategorii filmów w którzy grali aktorzy wraz ze statystykami - Sprawdzenie czy aktorzy graj¹cy w najwiêkszej liczbie filmów s¹ tacy sami w 10% najczêœciej oraz 10% najrzadziej wypo¿yczonych filmach? - Sprawdzenie zzy aktorzy graj¹cy w najwiêkszej liczbie filmów s¹ tacy sami w 25% najczêœciej oraz 25% najrzadziej wypo¿yczonych filmach?

### 8. Ranking wypo¿yczeñ filmów ze wzglêdu na ich dostêpnoœæ w wypo¿yczalni

------------------------------------------------------------------------

*Task_8*

Wyznaczenie zale¿noœci miêdzy stanem magazynowym filmów a iloœci¹ ich wypo¿yczeñ. Analiza œredniej wypo¿yczeñ wzglêdem zapasu filmów w wypo¿yczalni.

## Podsumowanie

-   Brak istotnego wp³ywu aktora na liczbê wypo¿yczeñ, mierz¹c œredni¹ liczbê wypo¿yczeñ per film na aktora.
-   Aktorzy maj¹ wp³yw na dochód z wypo¿yczeñ. (Wysoki dochód generowali nastêpuj¹cy aktorzy: K. Paltrow, N. Degeneres, G. Heston, T. Miranda).
-   Aktor nie ma wp³ywu na ca³kowity czas wypo¿yczenia filmu w którym gra³.
-   Bez wzglêdu na miejsca w rankingu aktorów grali oni zarówno w tych bardziej jak i tych mniej popularnych filmach.
-   Aktor nie ma wp³ywu na wypo¿yczenia filmu ze wzglêdu na cenê jego wypo¿yczenia.
-   Nie odnotowano zale¿noœci pomiêdzy aktorem, a konkretn¹ kategori¹ filmu. (Ka¿dy z aktorów wystêpowa³ w przynajmniej jednym filmie z konkretnej kategorii).
-   Analizuj¹c œredni¹ liczbê wypo¿yczeñ z danym aktorem na stan magazynowy trudno stwierdziæ przy posiadanych danych ze wzglêdu na niewielkie odchylenie wokó³ wartoœci œredniej czy dany aktor wp³ywa na popularnoœæ filmów, w których gra.
