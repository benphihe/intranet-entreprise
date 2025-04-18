#!/bin/bash

# Script de restauration de l'intranet
# Nécessite les droits root/sudo

# Configuration
BACKUP_DIR="/backup"
LOG_FILE="/var/log/restore.log"

# Fonction pour logger
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Vérification des arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <date_de_sauvegarde>"
    echo "Format de la date: YYYYMMDD"
    exit 1
fi

BACKUP_DATE=$1
BACKUP_PATH="$BACKUP_DIR/$BACKUP_DATE"

# Vérification de l'existence de la sauvegarde
if [ ! -d "$BACKUP_PATH" ]; then
    log "ERREUR: La sauvegarde du $BACKUP_DATE n'existe pas"
    exit 1
fi

# Arrêt des services
log "Arrêt des services..."
systemctl stop slapd
systemctl stop apache2
systemctl stop mariadb
systemctl stop postfix
systemctl stop dovecot
systemctl stop smbd
systemctl stop nagios3

# Restauration LDAP
log "Début de la restauration LDAP"
if [ -f "$BACKUP_PATH/ldap.ldif" ]; then
    slapadd -b "dc=entreprise,dc=com" -l "$BACKUP_PATH/ldap.ldif"
    if [ $? -eq 0 ]; then
        log "Restauration LDAP réussie"
    else
        log "ERREUR: Échec de la restauration LDAP"
        exit 1
    fi
fi

# Restauration des bases de données
log "Début de la restauration des bases de données"
if [ -f "$BACKUP_PATH/mysql.sql" ]; then
    mysql < "$BACKUP_PATH/mysql.sql"
    if [ $? -eq 0 ]; then
        log "Restauration des bases de données réussie"
    else
        log "ERREUR: Échec de la restauration des bases de données"
        exit 1
    fi
fi

# Restauration des fichiers partagés
log "Début de la restauration des fichiers partagés"
if [ -f "$BACKUP_PATH/files.tar.gz" ]; then
    rm -rf /srv/samba/share/*
    tar xzf "$BACKUP_PATH/files.tar.gz" -C /
    if [ $? -eq 0 ]; then
        log "Restauration des fichiers partagés réussie"
    else
        log "ERREUR: Échec de la restauration des fichiers partagés"
        exit 1
    fi
fi

# Restauration des configurations
log "Début de la restauration des configurations"
if [ -f "$BACKUP_PATH/config.tar.gz" ]; then
    tar xzf "$BACKUP_PATH/config.tar.gz" -C /
    if [ $? -eq 0 ]; then
        log "Restauration des configurations réussie"
    else
        log "ERREUR: Échec de la restauration des configurations"
        exit 1
    fi
fi

# Redémarrage des services
log "Redémarrage des services..."
systemctl start slapd
systemctl start apache2
systemctl start mariadb
systemctl start postfix
systemctl start dovecot
systemctl start smbd
systemctl start nagios3

# Vérification de l'état des services
log "Vérification de l'état des services..."
for service in slapd apache2 mariadb postfix dovecot smbd nagios3; do
    if systemctl is-active --quiet $service; then
        log "$service est actif"
    else
        log "ATTENTION: $service n'est pas actif"
    fi
done

log "Restauration terminée avec succès"
exit 0 