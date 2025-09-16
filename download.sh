#!/bin/bash
set -e

URL="https://www.kaggle.com/api/v1/datasets/download/eshummalik/bmw-sales-dataset"
ZIP="/tmp/data.zip"
EXTRACT_DIR="/tmp/extracted_csv"
CSV_LOCAL="/tmp/data.csv"
HDFS_PATH="/csv/data.csv"

# Créer dossier temporaire pour extraction
mkdir -p "$EXTRACT_DIR"

# Télécharger le zip
curl -s -L -o "$ZIP" "$URL"

# Extraire le contenu dans le dossier temporaire
unzip -o "$ZIP" -d "$EXTRACT_DIR"

# Trouver le fichier CSV extrait
CSV_FILE=$(ls "$EXTRACT_DIR"/*.csv | head -n 1)

# Le renommer uniformément
mv "$CSV_FILE" "$CSV_LOCAL"

# Créer le dossier HDFS si besoin
hdfs dfs -mkdir -p /csv || true

# Uploader dans HDFS (remplace l'ancien)
hdfs dfs -put -f "$CSV_LOCAL" "$HDFS_PATH"

echo "$(date) - CSV mis à jour dans HDFS : $HDFS_PATH"