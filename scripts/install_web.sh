#!/bin/bash

# Script d'installation et configuration du serveur web
# Nécessite les droits root/sudo

# Mise à jour du système
apt-get update
apt-get upgrade -y

# Installation d'Apache et des modules nécessaires
apt-get install -y apache2 libapache2-mod-php php php-ldap php-mysql

# Configuration d'Apache
a2enmod ssl
a2enmod rewrite
a2enmod php

# Création du répertoire pour le portail
mkdir -p /var/www/intranet
chown -R www-data:www-data /var/www/intranet

# Configuration du virtual host
cat > /etc/apache2/sites-available/intranet.conf <<EOF
<VirtualHost *:80>
    ServerName intranet.entreprise.com
    DocumentRoot /var/www/intranet
    
    <Directory /var/www/intranet>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/intranet-error.log
    CustomLog \${APACHE_LOG_DIR}/intranet-access.log combined
</VirtualHost>
EOF

# Activation du site
a2ensite intranet.conf
systemctl restart apache2

# Installation de phpLDAPadmin pour la gestion web de LDAP
apt-get install -y phpldapadmin

# Configuration de phpLDAPadmin
sed -i "s/\$servers->setValue('login','attr','uid');/\$servers->setValue('login','attr','dn');/" /etc/phpldapadmin/config.php
sed -i "s/\$servers->setValue('login','anon_bind',true);/\$servers->setValue('login','anon_bind',false);/" /etc/phpldapadmin/config.php

# Redémarrage d'Apache
systemctl restart apache2

echo "Installation du serveur web terminée"
echo "Le portail est accessible sur http://intranet.entreprise.com"
echo "phpLDAPadmin est accessible sur http://intranet.entreprise.com/phpldapadmin" 