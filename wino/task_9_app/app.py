import numpy as np
from sklearn.preprocessing import StandardScaler
from flask import Flask, request, jsonify, render_template
import pickle

#wczytuje classe modelu flask
app = Flask(__name__)

#wczytuje nasz zapiklowany model i scaler
model = pickle.load(open('model_final_xgb.pkl', 'rb'))
scaler = pickle.load(open('scaler.pkl', 'rb'))

#pobiera nasz template strony
@app.route('/')
def home():
    return render_template('index.html')

#pobiera wprowadzone przez nas dane na stronie
@app.route('/predict',methods=['POST']) 
def predict():

    int_features = [float(x) for x in request.form.values()]
    final_features1 = [np.array(int_features)]
    #definicja domyslnych ustawien modelu, dla parametru 4,5 i 8 
    # oraz podzielenie zbioru tak zeby wcisnac te domyslne wartosci parametrow pomiedzy wprowadzone dane 
    # i doprowadzic do wymaganej postaci dla predykcji
    a = final_features1[0][0:4]
    defaults_4_5 = np.array([0.06,13])
    b = final_features1[0][4:6]
    defaults_8 = np.array([3.31])
    c = final_features1[0][6:]

    #laczenie w zbior do predykcji
    final_features = [np.hstack([a,defaults_4_5,b, defaults_8,c ])]
    prediction = model.predict(scaler.transform(final_features))

    output = ["poor, not drink it. Life is too short" if prediction[0] == 1 else "good, i recommend"]

    return render_template('index.html', prediction_text="Your wine is  {}".format(output).replace("['", "").replace("']",""))

@app.route('/results',methods=['POST'])
def results():

    data = request.get_json(force=True)
    prediction = model.predict([np.array(list(data.values()))])

    output = prediction[0]
    return jsonify(output)

if __name__ == "__main__":
    app.run(debug=True)