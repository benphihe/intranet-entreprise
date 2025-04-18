#!/bin/bash

# Script d'installation et configuration du serveur de base de données
# Nécessite les droits root/sudo

# Mise à jour du système
apt-get update
apt-get upgrade -y

# Installation de MariaDB
apt-get install -y mariadb-server

# Configuration de MariaDB
cat > /etc/mysql/mariadb.conf.d/50-server.cnf <<EOF
[mysqld]
bind-address = 127.0.0.1
port = 3306
user = mysql
pid-file = /var/run/mysqld/mysqld.pid
socket = /var/run/mysqld/mysqld.sock
basedir = /usr
datadir = /var/lib/mysql
tmpdir = /tmp
lc-messages-dir = /usr/share/mysql
character-set-server = utf8mb4
collation-server = utf8mb4_general_ci
max_connections = 100
max_allowed_packet = 16M
thread_cache_size = 128
key_buffer_size = 128M
table_open_cache = 400
myisam_sort_buffer_size = 512M
net_buffer_length = 16K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
sort_buffer_size = 512K
innodb_buffer_pool_size = 256M
innodb_log_file_size = 64M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 50
EOF

# Création de la base de données pour Roundcube
mysql -e "CREATE DATABASE roundcubemail;"
mysql -e "CREATE USER 'roundcube'@'localhost' IDENTIFIED BY 'mot_de_passe';"
mysql -e "GRANT ALL PRIVILEGES ON roundcubemail.* TO 'roundcube'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Import du schéma de la base de données Roundcube
mysql roundcubemail < /usr/share/roundcube/SQL/mysql.initial.sql

# Redémarrage de MariaDB
systemctl restart mariadb

echo "Installation du serveur de base de données terminée"
echo "La base de données est accessible sur localhost:3306"
echo "Identifiants Roundcube :"
echo "  - Utilisateur : roundcube"
echo "  - Mot de passe : mot_de_passe"
echo "  - Base de données : roundcubemail" 