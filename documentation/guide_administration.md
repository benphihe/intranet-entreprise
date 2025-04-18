# Guide d'Administration de l'Intranet

## Table des matières
1. [Architecture](#architecture)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Maintenance](#maintenance)
5. [Sécurité](#sécurité)
6. [Dépannage](#dépannage)

## Architecture

### Composants
- **Serveur LDAP** : OpenLDAP
  - Port : 389 (LDAP), 636 (LDAPS)
  - Base DN : dc=entreprise,dc=com
  - Structure : ou=people, ou=groups

- **Serveur Web** : Apache
  - Ports : 80 (HTTP), 443 (HTTPS)
  - Virtual Hosts :
    - intranet.entreprise.com
    - mail.entreprise.com

- **Serveur de Base de Données** : MariaDB
  - Port : 3306
  - Bases :
    - roundcubemail
    - autres applications

- **Serveur de Messagerie**
  - Postfix (SMTP)
  - Dovecot (IMAP/POP3)
  - Roundcube (Webmail)

- **Serveur de Fichiers** : Samba
  - Partage : /srv/samba/share
  - Groupe : sambashare

- **Monitoring** : Nagios
  - Port : 80
  - Plugins NRPE

## Installation

### Prérequis
- Ubuntu Server 22.04 LTS
- 8 Go RAM minimum
- 100 Go espace disque
- Accès root/sudo

### Procédure d'installation
1. Cloner le dépôt
2. Exécuter `./scripts/install_all.sh`
3. Configurer les mots de passe
4. Mettre à jour les certificats SSL
5. Configurer le pare-feu

## Configuration

### LDAP
```bash
# Structure de base
dc=entreprise,dc=com
  ├── ou=people
  └── ou=groups

# Commandes utiles
ldapsearch -x -b "dc=entreprise,dc=com"
ldapadd -x -D "cn=admin,dc=entreprise,dc=com" -W -f fichier.ldif
```

### Apache
```apache
# Virtual Host exemple
<VirtualHost *:80>
    ServerName intranet.entreprise.com
    DocumentRoot /var/www/intranet
    <Directory /var/www/intranet>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

### MariaDB
```sql
-- Création d'un utilisateur
CREATE USER 'utilisateur'@'localhost' IDENTIFIED BY 'motdepasse';
GRANT ALL PRIVILEGES ON base.* TO 'utilisateur'@'localhost';
FLUSH PRIVILEGES;
```

### Postfix
```bash
# Configuration principale
myhostname = mail.entreprise.com
mydomain = entreprise.com
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
```

### Samba
```ini
[global]
   workgroup = WORKGROUP
   security = user
   passdb backend = tdbsam

[share]
   path = /srv/samba/share
   valid users = @sambashare
   writable = yes
```

## Maintenance

### Sauvegardes
```bash
# Script de sauvegarde quotidienne
#!/bin/bash
BACKUP_DIR="/backup/$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

# Sauvegarde LDAP
slapcat -b "dc=entreprise,dc=com" > $BACKUP_DIR/ldap.ldif

# Sauvegarde bases de données
mysqldump --all-databases > $BACKUP_DIR/mysql.sql

# Sauvegarde fichiers
tar czf $BACKUP_DIR/files.tar.gz /srv/samba/share
```

### Mises à jour
```bash
# Mise à jour du système
apt-get update
apt-get upgrade

# Vérification des services
systemctl status slapd
systemctl status apache2
systemctl status mariadb
systemctl status postfix
systemctl status dovecot
systemctl status smbd
systemctl status nagios3
```

## Sécurité

### Pare-feu
```bash
# Règles iptables de base
iptables -A INPUT -p tcp --dport 22 -j ACCEPT   # SSH
iptables -A INPUT -p tcp --dport 80 -j ACCEPT   # HTTP
iptables -A INPUT -p tcp --dport 443 -j ACCEPT  # HTTPS
iptables -A INPUT -p tcp --dport 389 -j ACCEPT  # LDAP
iptables -A INPUT -p tcp --dport 636 -j ACCEPT  # LDAPS
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
```

### SSL/TLS
```bash
# Génération des certificats
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/server.key \
  -out /etc/ssl/certs/server.crt
```

## Dépannage

### Vérification des logs
```bash
# LDAP
tail -f /var/log/syslog | grep slapd

# Apache
tail -f /var/log/apache2/error.log

# MariaDB
tail -f /var/log/mysql/error.log

# Postfix
tail -f /var/log/mail.log

# Samba
tail -f /var/log/samba/log.smbd

# Nagios
tail -f /var/log/nagios3/nagios.log
```

### Tests de connectivité
```bash
# LDAP
ldapsearch -x -b "dc=entreprise,dc=com" -H ldap://localhost

# Web
curl -I http://localhost

# Base de données
mysql -u root -p -e "SHOW DATABASES;"

# Mail
telnet localhost 25
telnet localhost 143

# Samba
smbclient -L localhost -U%

# Monitoring
/usr/lib/nagios/plugins/check_nrpe -H localhost -c check_load
```

### Procédures de récupération
1. Identifier le problème via les logs
2. Vérifier l'état des services
3. Restaurer depuis la dernière sauvegarde si nécessaire
4. Documenter l'incident et la solution 