import requests

url = 'http://localhost:5000/results'
r = requests.post(url,json={'alcohol':5, 'sulphates':200, 'ph':400})

print(r.json())