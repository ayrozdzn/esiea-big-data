FROM madjidtaoualit/hadoop-cluster:latest

# Installer cron, curl, python3 et pip
RUN apt-get update && apt-get install -y \
    unzip \
    cron \
    curl \
    python3 \
    python3-pip \
 && rm -rf /var/lib/apt/lists/*

# Mettre pip à jour
RUN python3 -m pip install --upgrade pip

# Copier ton projet dashboard
COPY dashboard /root/dashboard

# Installer les dépendances Python du dashboard
RUN pip3 install --no-cache-dir -r /root/dashboard/requirements.txt

# Copier le script de téléchargement
COPY download.sh /root/download.sh
RUN chmod +x /root/download.sh

# Créer tâche cron : toutes les 6h par exemple
RUN echo "0 */6 * * * root /root/download.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/data-cron
RUN chmod 0644 /etc/cron.d/data-cron
RUN crontab /etc/cron.d/data-cron

# Ports Flask + Hadoop exposés
EXPOSE 5000 9870 8088 7077 16010

# Démarrer cron + dashboard Flask
CMD service ssh start && ./start-hadoop.sh && service cron start && ./download.sh && python3 /root/dashboard/app.py