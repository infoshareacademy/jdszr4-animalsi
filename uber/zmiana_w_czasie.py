#past

print("Ilosc obrazen w danym roku") 

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import ipywidgets as widgets
from IPython.display import clear_output

report=pd.read_csv("task5/task5.csv")

InjsevDict = {"brak obrazen": 0,
             "mozliwe obrazenia" : 1,
             "nieobezwladniajace obrazenia": 2,
             "obezwladniajace obrazenia": 3,
             "smierc": 4,
             "wielkosc obrazen nie jest znana": 5,
             "smierc przed wypadkiem": 6}

YearDict = {"2004": 2004,
             "2005" : 2005,
             "2006": 2006,
             "2007": 2007,
             "2008": 2008,
             "2009": 2009,
             "2010": 2010,
             "2011": 2011,
             "2012": 2012,
             "2013": 2013,
             "2014": 2014,
             "2015": 2015}

#pola wyboru definicje
Injsev = widgets.Dropdown(options = InjsevDict, description='Wielkosc obrazen:',style = {'description_width': '150px'},layout = {'width': '500px'})

run2 = widgets.Button(description = "wylicz",tooltip='Kliknij',icon='search',button_style='info')

out2 = widgets.Output()

def przycisk2(X):
    with out2:
        clear_output()
        plt.bar(report[report['INJSEV']==Injsev.value]['YEAR'], report[report['INJSEV']==Injsev.value]['RESULT'])
        plt.ylabel('ilosc danych obrazen')
        plt.xlabel('lata')
        plt.show()

values = {"option2": Injsev.value}

def gadzety2 (a):
    values["option2"] = a
