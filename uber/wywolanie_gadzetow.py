"ogolna informacja o pakiecie"

print("prezentacja aplikacji - kalkulator obrazen") 

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import ipywidgets as widgets
from IPython.display import clear_output

report=pd.read_csv("task7/dane_surowe_do_kalkulatora_task7.csv")

# Slownik danych
## wiek auta z przedzialu

CarAgeDict = {"0 - 2 lata": 0,
             "3 - 5 lat" : 1,
             "6 - 10 lat": 2,
             "11-20 lat":3,
             "21 -30 lat":4,
             "31 lat i wiecej": 5}

## marka auta z listy ponizej
MakeDict = {"Audi": 32,
            "BMW": 34,
            "Cadillac": 19,
            "Chevrolet": 20,
            "Chrysler": 6,
            "Deawoo": 64,
            "Dodge": 7,
            "Ford": 12,
            "Honda": 37,
            "Hyundai":55,
            "Isuzu":38,
            "Jeep":2,
            "Kia":63,
            "Land Rover":62,
            "Lexus":59,
            "Lincoln":13,
            "Mercedes":42,
            "Nissan":52,
            "Pontiac":22,
            "Porsche":45,
            "Saab":47,
            "Subaru":48,
            "Suzuki" :53,
            "Toyota": 49,
            "Volkswagen":30,
            "Volvo" :51,
            "Pozostale": 99}
            
## pozycja kierowcy

SeatposDict = {"Obok kierowcy" :1,
              "Drugi rzad":2 ,
              "Kolejny rzad": 3,
              "Niestandardowe miejsce": 4}

## DriverAge 

# 4: 17-21 lat
# 5: 22-30 lat
# 6: 31-50 lat
# 7: 51-65 lat
# 8: powyzej 66 lat

## plec kierowcy 

DriverSexDict = {"Kobieta" :2,
                 "Mezczyzna" :1}



#slider defincja
wiek_slider = widgets.IntSlider(value=20, min=16, max=100,  description = "Podaj wiek kierowcy",style= {'description_width': 'initial'})
def wiek_kierowcy(x):
    przedzial = 0
    if x <=21:
        przedzial = 4
    elif x<=30:
        przedzial = 5
    elif x<=50:
        przedzial = 6
    elif x <=65:
        przedzial = 7
    else:
        przedzial = 8
    return przedzial


#pola wyboru definicje
CarAge = widgets.Dropdown(options = CarAgeDict, description='Wiek auta:',style= {'description_width': 'initial'})
Make= widgets.Dropdown(options = MakeDict, description='Marka auta:',style= {'description_width': 'initial'})
Seatpos= widgets.Dropdown(options = SeatposDict, description='Miejsce siedzenia',style= {'description_width': 'initial'})
DriverSex =widgets.Dropdown(options = DriverSexDict,description='Plec kierowcy',style= {'description_width': 'initial'})



#definicja przycisku run
run = widgets.Button(description = "wylicz",tooltip='Kliknij',icon='search',button_style='info')

out = widgets.Output()
def przycisk(X):
    with out:
        clear_output()
        wiek = wiek_kierowcy(wiek_slider.value)
        wynik = report[(report["CarAge"]==CarAge.value) & (report["MAKE"]==Make.value)  & 
                       (report["SEATPOS"]==Seatpos.value) & (report["DriverSex"]==DriverSex.value) & 
                       (report["DriverAge"]==wiek)]
        print("W takiej konfiguracji prawdopodobienstwo wynosi:","\n",
        "- smierci: {:.1%}".format(round(wynik.loc[wynik["INJSEV"]==4,"TotalResult"].values[0],2)),"\n",
        "- powaznych obrazen: {:.1%}".format(round(wynik.loc[wynik["INJSEV"]==3,"TotalResult"].values[0],2)),"\n",
        "- lekkich obrazen: {:.1%}".format(round(wynik.loc[wynik["INJSEV"]==1,"TotalResult"].values[0],2)),"\n",  
        "- braku obrazen: {:.1%}".format(round(wynik.loc[wynik["INJSEV"]==0,"TotalResult"].values[0],2)))  


# polaczenie wszystkiego w jedna aplikacje

values = {"slider": wiek_slider.value, "option": CarAge.value,"option2": Make.value, "option3": Seatpos.value,"option4":DriverSex}


def gadzety(x,y,a,b,c):
    values["slider"] = x
    values["option"] = y
    values["option2"] = a
    values["option3"] = b
    values["option4"] = c













