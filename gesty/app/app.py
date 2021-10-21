import numpy as np
import tensorflow as tf
import cv2
import os
from flask import Flask, render_template, request, redirect
from preprocessing.dane import *


# Files Upload
# path = os.chdir('C:/Users/Dawid/Desktop/kurs/jdszr4-animalsi/gesty/app')
path = os.getcwd()
UPLOAD_FOLDER = os.path.join(path, 'static/images')
ALLOWED_EXTENSIONS = set(['png', 'jpg', 'jpeg'])

# Instatiate flask app  
app = Flask(__name__, template_folder='./templates')
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER


@app.route('/',methods=['GET', 'POST'])
def index():
    return render_template('index.html')



@app.route('/upload', methods=['POST', 'GET'])
def upload_file():
    if request.method == 'POST':
        # Check if the post request has the file part
        if 'file' not in request.files:
            flash('No file part')
            return redirect(request.url)
        file = request.files['file']
        if file.filename == '':
            flash('No file selected for uploading')
            return redirect(request.url)
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            flash('File successfully uploaded')
            return redirect('/predict')
        else:
            flash('Allowed file types are: png, jpg, jpeg')
            return redirect(request.url)
    return render_template('upload.html')


#wczytuje nasz model
model = tf.keras.models.load_model("model_dt.h5")



@app.route('/predict', methods = ['GET','POST'])
def predict():
    #pobieramy nowe zdjecie z folderu
    file1 = request.files['file']
    filename1 = file1.filename
    file_path = os.path.join(os.path.join(path, 'static/images/'),filename1)
    file1.save(file_path)
    
    nowe_foto =cv2.imread(file_path,cv2.IMREAD_UNCHANGED)

    #zapisujemy je w skali szarosci
    gray = cv2.cvtColor(nowe_foto, cv2.COLOR_BGR2GRAY)
    
    #docelowy format zdjecia w modelu to 28 x 28, dlatego     przeskalujmy zdjecie do tego formatu
    dim = (28, 28)

    resized = cv2.resize(gray, dim, interpolation = cv2.INTER_AREA)

    resized1 = resized.reshape(-1,28,28,1)

    #predykcja nowego zdjecia
    prediction  = model.predict(resized1).argmax(axis = 1)

    output = slownik[prediction[0]]
    return render_template('index.html', prediction_text="This letter is {}".format(output))

@app.route('/results',methods=['POST'])
def results():
    data = request.get_json(force=True)
    prediction = model.predict(resized1).argmax(axis = 1)
    output = slownik[wynik[0]]
    return jsonify(output)

if __name__ == "__main__":
    app.run(debug=True)