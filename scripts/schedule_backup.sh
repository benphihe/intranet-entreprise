#!/bin/bash

# Script de planification des sauvegardes
# Nécessite les droits root/sudo

# Configuration
BACKUP_SCRIPT="/chemin/vers/backup.sh"
LOG_FILE="/var/log/backup.log"
CRON_JOB="0 2 * * * $BACKUP_SCRIPT >> $LOG_FILE 2>&1"

# Vérification de l'installation de cron
if ! command -v crontab &> /dev/null; then
    echo "Installation de cron..."
    apt-get update
    apt-get install -y cron
fi

# Vérification si le job existe déjà
if crontab -l | grep -q "$BACKUP_SCRIPT"; then
    echo "Le job de sauvegarde existe déjà dans crontab"
    exit 0
fi

# Ajout du job dans crontab
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

if [ $? -eq 0 ]; then
    echo "Le job de sauvegarde a été ajouté avec succès"
    echo "La sauvegarde s'exécutera tous les jours à 2h du matin"
else
    echo "ERREUR: Échec de l'ajout du job dans crontab"
    exit 1
fi

# Vérification de l'état du service cron
systemctl is-active cron >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Démarrage du service cron..."
    systemctl start cron
    systemctl enable cron
fi

echo "Configuration terminée avec succès"
exit 0 