#!/bin/bash

# Script de vérification des services
# Nécessite les droits root/sudo

# Configuration
LOG_FILE="/var/log/services_check.log"
SERVICES=(
    "slapd"
    "apache2"
    "mariadb"
    "postfix"
    "dovecot"
    "smbd"
    "nagios3"
)

# Fonction pour logger
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Fonction pour vérifier un service
check_service() {
    local service=$1
    if systemctl is-active --quiet $service; then
        log "$service est actif"
        return 0
    else
        log "ERREUR: $service n'est pas actif"
        return 1
    fi
}

# Fonction pour redémarrer un service
restart_service() {
    local service=$1
    log "Redémarrage de $service..."
    systemctl restart $service
    if [ $? -eq 0 ]; then
        log "$service redémarré avec succès"
        return 0
    else
        log "ERREUR: Échec du redémarrage de $service"
        return 1
    fi
}

# Vérification des services
log "Début de la vérification des services"
ERROR_COUNT=0

for service in "${SERVICES[@]}"; do
    if ! check_service $service; then
        ERROR_COUNT=$((ERROR_COUNT + 1))
        if restart_service $service; then
            ERROR_COUNT=$((ERROR_COUNT - 1))
        fi
    fi
done

# Vérification des ports
log "Vérification des ports"
PORTS=(
    "389"  # LDAP
    "636"  # LDAPS
    "80"   # HTTP
    "443"  # HTTPS
    "3306" # MySQL
    "25"   # SMTP
    "143"  # IMAP
    "445"  # SMB
)

for port in "${PORTS[@]}"; do
    if netstat -tuln | grep -q ":$port "; then
        log "Port $port est ouvert"
    else
        log "ERREUR: Port $port n'est pas ouvert"
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
done

# Vérification de l'espace disque
log "Vérification de l'espace disque"
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 90 ]; then
    log "ATTENTION: L'espace disque est à $DISK_USAGE%"
    ERROR_COUNT=$((ERROR_COUNT + 1))
else
    log "Espace disque OK: $DISK_USAGE% utilisé"
fi

# Vérification de la mémoire
log "Vérification de la mémoire"
MEM_USAGE=$(free | awk '/Mem/{printf("%.0f"), $3/$2 * 100}')
if [ $MEM_USAGE -gt 90 ]; then
    log "ATTENTION: La mémoire est à $MEM_USAGE%"
    ERROR_COUNT=$((ERROR_COUNT + 1))
else
    log "Mémoire OK: $MEM_USAGE% utilisée"
fi

# Conclusion
if [ $ERROR_COUNT -eq 0 ]; then
    log "Tous les services sont opérationnels"
    exit 0
else
    log "ATTENTION: $ERROR_COUNT problème(s) détecté(s)"
    exit 1
fi 