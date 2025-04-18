#!/bin/bash

# Script de planification des vérifications de services
# Nécessite les droits root/sudo

# Configuration
CHECK_SCRIPT="/chemin/vers/check_services.sh"
LOG_FILE="/var/log/services_check.log"
CRON_JOB="*/15 * * * * $CHECK_SCRIPT >> $LOG_FILE 2>&1"

# Vérification de l'installation de cron
if ! command -v crontab &> /dev/null; then
    echo "Installation de cron..."
    apt-get update
    apt-get install -y cron
fi

# Vérification si le job existe déjà
if crontab -l | grep -q "$CHECK_SCRIPT"; then
    echo "Le job de vérification existe déjà dans crontab"
    exit 0
fi

# Ajout du job dans crontab
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

if [ $? -eq 0 ]; then
    echo "Le job de vérification a été ajouté avec succès"
    echo "La vérification s'exécutera toutes les 15 minutes"
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

# Configuration des alertes par email
if ! command -v mail &> /dev/null; then
    echo "Installation de mailutils..."
    apt-get update
    apt-get install -y mailutils
fi

# Ajout d'une alerte en cas d'erreur
echo "if [ \$? -ne 0 ]; then echo \"Des problèmes ont été détectés sur les services. Veuillez consulter $LOG_FILE\" | mail -s \"Alerte Services\" admin@entreprise.com; fi" >> $CHECK_SCRIPT

echo "Configuration terminée avec succès"
exit 0 