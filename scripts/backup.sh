#!/bin/bash

# Script de sauvegarde de l'intranet
# Nécessite les droits root/sudo

# Configuration
BACKUP_DIR="/backup"
LOG_FILE="/var/log/backup.log"
RETENTION_DAYS=30

# Fonction pour logger
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Création du répertoire de sauvegarde
mkdir -p $BACKUP_DIR/$(date +%Y%m%d)

# Sauvegarde LDAP
log "Début de la sauvegarde LDAP"
slapcat -b "dc=entreprise,dc=com" > $BACKUP_DIR/$(date +%Y%m%d)/ldap.ldif
if [ $? -eq 0 ]; then
    log "Sauvegarde LDAP réussie"
else
    log "ERREUR: Échec de la sauvegarde LDAP"
    exit 1
fi

# Sauvegarde des bases de données
log "Début de la sauvegarde des bases de données"
mysqldump --all-databases > $BACKUP_DIR/$(date +%Y%m%d)/mysql.sql
if [ $? -eq 0 ]; then
    log "Sauvegarde des bases de données réussie"
else
    log "ERREUR: Échec de la sauvegarde des bases de données"
    exit 1
fi

# Sauvegarde des fichiers partagés
log "Début de la sauvegarde des fichiers partagés"
tar czf $BACKUP_DIR/$(date +%Y%m%d)/files.tar.gz /srv/samba/share
if [ $? -eq 0 ]; then
    log "Sauvegarde des fichiers partagés réussie"
else
    log "ERREUR: Échec de la sauvegarde des fichiers partagés"
    exit 1
fi

# Sauvegarde des configurations
log "Début de la sauvegarde des configurations"
tar czf $BACKUP_DIR/$(date +%Y%m%d)/config.tar.gz \
    /etc/ldap \
    /etc/apache2 \
    /etc/mysql \
    /etc/postfix \
    /etc/dovecot \
    /etc/samba \
    /etc/nagios3
if [ $? -eq 0 ]; then
    log "Sauvegarde des configurations réussie"
else
    log "ERREUR: Échec de la sauvegarde des configurations"
    exit 1
fi

# Nettoyage des anciennes sauvegardes
log "Nettoyage des anciennes sauvegardes"
find $BACKUP_DIR -type d -mtime +$RETENTION_DAYS -exec rm -rf {} \;
if [ $? -eq 0 ]; then
    log "Nettoyage des anciennes sauvegardes réussi"
else
    log "ERREUR: Échec du nettoyage des anciennes sauvegardes"
    exit 1
fi

# Vérification de l'espace disque
DISK_USAGE=$(df -h $BACKUP_DIR | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 90 ]; then
    log "ATTENTION: L'espace disque est à $DISK_USAGE%"
fi

log "Sauvegarde terminée avec succès"
exit 0 