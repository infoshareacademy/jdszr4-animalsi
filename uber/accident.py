import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import ipywidgets as widgets
from IPython.display import clear_output

wyniki = pd.read_csv('result.csv')

choice_widget = widgets.Dropdown(
                                 options=["2", "3", "4", "5", "6", "7", "8",
                                           "9", "10", "11", "13", "14", "15", "17", "18", "19"],
                                 description='Osoby:',
                                 disabled=False
)

values = {         
          "option": choice_widget.value
         }

def przycisk(option_choice):
    values["option"] = option_choice
    if option_choice == choice_widget.value:  
        print("Dla takiej liczby pasażerów w aucie prawdopodobienstwo:","\n",
              "- smierci to: {} %".format(round(len(wyniki.loc[(wyniki["Numer"]== pd.to_numeric(choice_widget.value, downcast='float')) & (wyniki["Obrazenia"]==1)])/ 
                                            len(wyniki.loc[(wyniki["Numer"]== pd.to_numeric(choice_widget.value, downcast='float'))])*100, 2)),"\n",
              
              "- powaznych obrazen z pobytem w szpitalu to: {} %".format(round(len(wyniki.loc[(wyniki["Numer"]==pd.to_numeric(choice_widget.value, downcast='float')) & (wyniki["Obrazenia"]==2)])/
                                                len(wyniki.loc[(wyniki["Numer"]== pd.to_numeric(choice_widget.value, downcast='float'))])*100, 2)), "\n",
              "- powaznych obrazen to: {} %".format(round(len(wyniki.loc[(wyniki["Numer"]==pd.to_numeric(choice_widget.value, downcast='float')) & (wyniki["Obrazenia"]==3)])/
                                                len(wyniki.loc[(wyniki["Numer"]== pd.to_numeric(choice_widget.value, downcast='float'))])*100, 2)), "\n",
              "- niewielkich obrazen z pobytem w szpitalu to: {} %".format(round(len(wyniki.loc[(wyniki["Numer"]==pd.to_numeric(choice_widget.value, downcast='float')) & (wyniki["Obrazenia"]==4)])/
                                                len(wyniki.loc[(wyniki["Numer"]== pd.to_numeric(choice_widget.value, downcast='float'))])*100, 2)), "\n",
              "- niewielkich obrazen to: {} %".format(round(len(wyniki.loc[(wyniki["Numer"]==pd.to_numeric(choice_widget.value, downcast='float')) & (wyniki["Obrazenia"]==5)])/
                                                len(wyniki.loc[(wyniki["Numer"]== pd.to_numeric(choice_widget.value, downcast='float'))])*100, 2)), "\n"
             )
     