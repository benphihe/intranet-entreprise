#!/bin/bash

# Script de configuration du pare-feu
# Nécessite les droits root/sudo

# Configuration
LOG_FILE="/var/log/firewall.log"

# Fonction pour logger
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Vérification de l'installation d'iptables
if ! command -v iptables &> /dev/null; then
    log "Installation d'iptables..."
    apt-get update
    apt-get install -y iptables
fi

# Sauvegarde des règles existantes
log "Sauvegarde des règles existantes..."
iptables-save > /etc/iptables.rules.old

# Réinitialisation des règles
log "Réinitialisation des règles..."
iptables -F
iptables -X
iptables -Z

# Politiques par défaut
log "Configuration des politiques par défaut..."
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Autorisation du trafic local
log "Configuration du trafic local..."
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Autorisation des connexions établies
log "Configuration des connexions établies..."
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Services internes
log "Configuration des services internes..."
SERVICES=(
    "22"    # SSH
    "80"    # HTTP
    "443"   # HTTPS
    "389"   # LDAP
    "636"   # LDAPS
    "3306"  # MySQL
    "25"    # SMTP
    "143"   # IMAP
    "445"   # SMB
)

for port in "${SERVICES[@]}"; do
    iptables -A INPUT -p tcp --dport $port -j ACCEPT
    log "Port $port ouvert"
done

# Protection contre les attaques
log "Configuration de la protection contre les attaques..."
# Protection contre les scans de ports
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

# Protection contre les attaques SYN
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP

# Limitation des connexions
iptables -A INPUT -p tcp --dport 22 -m connlimit --connlimit-above 3 -j DROP
iptables -A INPUT -p tcp --dport 80 -m connlimit --connlimit-above 20 -j DROP

# Sauvegarde des nouvelles règles
log "Sauvegarde des nouvelles règles..."
iptables-save > /etc/iptables.rules

# Configuration du chargement des règles au démarrage
log "Configuration du chargement des règles au démarrage..."
cat > /etc/network/if-pre-up.d/iptables <<EOF
#!/bin/bash
/sbin/iptables-restore < /etc/iptables.rules
EOF

chmod +x /etc/network/if-pre-up.d/iptables

# Vérification des règles
log "Vérification des règles..."
iptables -L -n

log "Configuration du pare-feu terminée avec succès"
exit 0 