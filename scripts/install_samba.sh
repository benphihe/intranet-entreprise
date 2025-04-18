#!/bin/bash

# Script d'installation et configuration de Samba
# Nécessite les droits root/sudo

# Mise à jour du système
apt-get update
apt-get upgrade -y

# Installation de Samba
apt-get install -y samba samba-common-bin

# Création du répertoire de partage
mkdir -p /srv/samba/share
chmod 2770 /srv/samba/share
chown root:sambashare /srv/samba/share

# Configuration de Samba
cat > /etc/samba/smb.conf <<EOF
[global]
   workgroup = WORKGROUP
   server string = Serveur de fichiers
   security = user
   map to guest = bad user
   name resolve order = bcast host
   dns proxy = no
   log file = /var/log/samba/log.%m
   max log size = 1000
   syslog = 0
   panic action = /usr/share/samba/panic-action %d
   server role = standalone server
   passdb backend = tdbsam
   obey pam restrictions = yes
   unix password sync = yes
   passwd program = /usr/bin/passwd %u
   passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
   pam password change = yes
   map to guest = bad user
   usershare allow guests = no

[share]
   comment = Partage de fichiers
   path = /srv/samba/share
   valid users = @sambashare
   force group = sambashare
   create mask = 0660
   directory mask = 2770
   writable = yes
EOF

# Création du groupe sambashare
groupadd sambashare

# Redémarrage de Samba
systemctl restart smbd
systemctl enable smbd

echo "Installation de Samba terminée"
echo "Pour ajouter un utilisateur à Samba : smbpasswd -a nom_utilisateur"
echo "Pour activer un utilisateur : smbpasswd -e nom_utilisateur" 