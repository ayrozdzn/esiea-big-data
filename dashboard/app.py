from flask import Flask, render_template, jsonify, request
import pandas as pd
import requests
from io import StringIO

app = Flask(__name__)

# URL WebHDFS (modifiez l'hôte si besoin)
HDFS_URL = "http://hadoop-master:9870/webhdfs/v1/csv/data.csv?op=OPEN"

def fetch_csv():
    resp = requests.get(HDFS_URL)
    resp.raise_for_status()
    df = pd.read_csv(StringIO(resp.text))
    return df

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/models')
def models():
    df = fetch_csv()
    models_list = ["Tous"] + sorted(df["Model"].dropna().unique().tolist())
    return jsonify(models_list)

@app.route('/api/sales')
def sales():
    model = request.args.get("model", "Tous")
    df = fetch_csv()
    if model != "Tous":
        df = df[df["Model"] == model]

    # Somme des ventes par année
    counts = df.groupby('Year')['Sales_Volume'].sum().to_dict()
    # Pour avoir toutes les années du dataset même si certaines n'ont pas de ventes
    # On convertit explicitement les clés en str pour éviter l'erreur TypeError: keys must be str, int, float, bool or None, not int64
    all_years = {str(year): int(counts.get(year, 0)) for year in sorted(df['Year'].unique())}
    return jsonify(all_years)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
