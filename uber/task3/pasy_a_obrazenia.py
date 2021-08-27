#pasy

print("wpływ pasów na obrazenia") 
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import ipywidgets as widgets
from IPython.display import clear_output

report=pd.read_csv("/Users/kamilakocot/Desktop/GIT/ANIMALSI - PROJEKT 1808/jdszr4-animalsi/uber/task3/task3.csv")

ManuseDict = {"brak pasów": 1,
             "były pasy" : 2}

InjsevDict = {"brak obrazeń": 0,
             "mozliwe obrazenia" : 1,
             "nieobezwładniające obrazenia": 2,
             "obezwladniajace obrazenia": 3,
             "śmierć": 4,
             "wielkość obrazeń nie jest znana": 5,
             "śmierć przed wypadkiem": 6}

#pola wyboru definicje
Manuse = widgets.Dropdown(options = ManuseDict, description='Obecność pasów:',style = {'description_width': '150px'},layout = {'width': '500px'})
Injsev= widgets.Dropdown(options = InjsevDict, description='Wielkosc obrazen:',style = {'description_width': '150px'},layout = {'width': '500px'})


#definicja przycisku run
run3 = widgets.Button(description = "wylicz",tooltip='Kliknij',icon='search',button_style='info')

out3 = widgets.Output()
def przycisk3(X):
    with out3:
        clear_output()
        wynik = report[(report["MANUSE"]==Manuse.value) & (report["INJSEV"]==Injsev.value)]
        print("prawdopodobienstwo w tej konfiguracji: ")
        print("{:.1%}".format(round(wynik["RESULT"].values[0],2)))
# polaczenie wszystkiego w jedna aplikacje

values = {"option": Manuse.value,"option2": Injsev.value}


def gadzety3(y,a):
    values["option"] = y
    values["option2"] = a