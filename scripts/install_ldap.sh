#!/bin/bash

# Script d'installation et configuration d'OpenLDAP
# Nécessite les droits root/sudo

# Mise à jour du système
apt-get update
apt-get upgrade -y

# Installation des paquets nécessaires
apt-get install -y slapd ldap-utils

# Configuration de l'annuaire LDAP
echo "Configuration de l'annuaire LDAP..."
echo "Veuillez entrer le nom de domaine LDAP (ex: dc=entreprise,dc=com) :"
read LDAP_DOMAIN
echo "Veuillez entrer le mot de passe administrateur LDAP :"
read -s LDAP_PASSWORD

# Configuration de slapd
debconf-set-selections <<EOF
slapd slapd/password1 password $LDAP_PASSWORD
slapd slapd/password2 password $LDAP_PASSWORD
slapd slapd/domain string $LDAP_DOMAIN
slapd shared/ldapns/ldap_server string ldap://localhost
EOF

dpkg-reconfigure -f noninteractive slapd

# Création de la structure de base
cat > /tmp/base.ldif <<EOF
dn: ou=people,$LDAP_DOMAIN
objectClass: organizationalUnit
ou: people

dn: ou=groups,$LDAP_DOMAIN
objectClass: organizationalUnit
ou: groups
EOF

ldapadd -x -D cn=admin,$LDAP_DOMAIN -w $LDAP_PASSWORD -f /tmp/base.ldif

# Configuration de la journalisation
cat > /etc/rsyslog.d/ldap.conf <<EOF
local4.* /var/log/ldap.log
EOF

systemctl restart rsyslog

echo "Installation d'OpenLDAP terminée"
echo "Le serveur LDAP est accessible sur ldap://localhost"
echo "Les logs sont disponibles dans /var/log/ldap.log" 