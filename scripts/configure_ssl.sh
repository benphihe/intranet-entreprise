#!/bin/bash

# Script de configuration SSL
# Nécessite les droits root/sudo

# Configuration
SSL_DIR="/etc/ssl"
CERT_DIR="$SSL_DIR/certs"
KEY_DIR="$SSL_DIR/private"
DOMAINS=(
    "intranet.entreprise.com"
    "mail.entreprise.com"
)
LOG_FILE="/var/log/ssl_config.log"

# Fonction pour logger
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Vérification de l'installation d'OpenSSL
if ! command -v openssl &> /dev/null; then
    log "Installation d'OpenSSL..."
    apt-get update
    apt-get install -y openssl
fi

# Création des répertoires
log "Création des répertoires SSL..."
mkdir -p $CERT_DIR $KEY_DIR
chmod 700 $KEY_DIR

# Génération des certificats pour chaque domaine
for domain in "${DOMAINS[@]}"; do
    log "Génération du certificat pour $domain..."
    
    # Génération de la clé privée
    openssl genrsa -out $KEY_DIR/$domain.key 2048
    chmod 600 $KEY_DIR/$domain.key
    
    # Génération de la demande de signature
    openssl req -new -key $KEY_DIR/$domain.key -out $SSL_DIR/$domain.csr -subj "/CN=$domain/O=Entreprise/C=FR"
    
    # Génération du certificat
    openssl x509 -req -days 365 -in $SSL_DIR/$domain.csr -signkey $KEY_DIR/$domain.key -out $CERT_DIR/$domain.crt
    
    # Vérification du certificat
    if openssl x509 -in $CERT_DIR/$domain.crt -noout -text | grep -q "CN=$domain"; then
        log "Certificat pour $domain généré avec succès"
    else
        log "ERREUR: Échec de la génération du certificat pour $domain"
        exit 1
    fi
done

# Configuration d'Apache
log "Configuration d'Apache pour SSL..."
a2enmod ssl

# Configuration des virtual hosts SSL
for domain in "${DOMAINS[@]}"; do
    cat > /etc/apache2/sites-available/$domain-ssl.conf <<EOF
<VirtualHost *:443>
    ServerName $domain
    DocumentRoot /var/www/$domain
    
    SSLEngine on
    SSLCertificateFile $CERT_DIR/$domain.crt
    SSLCertificateKeyFile $KEY_DIR/$domain.key
    
    <Directory /var/www/$domain>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/$domain-ssl-error.log
    CustomLog \${APACHE_LOG_DIR}/$domain-ssl-access.log combined
</VirtualHost>
EOF
    
    a2ensite $domain-ssl.conf
done

# Redémarrage d'Apache
log "Redémarrage d'Apache..."
systemctl restart apache2

# Vérification des certificats
log "Vérification des certificats..."
for domain in "${DOMAINS[@]}"; do
    if curl -vI https://$domain 2>&1 | grep -q "SSL certificate verify ok"; then
        log "Certificat SSL pour $domain vérifié avec succès"
    else
        log "ATTENTION: Problème avec le certificat SSL de $domain"
    fi
done

log "Configuration SSL terminée avec succès"
exit 0 