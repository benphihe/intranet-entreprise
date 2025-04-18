#!/bin/bash

# Script principal d'installation de l'intranet
# Nécessite les droits root/sudo

# Fonction pour afficher un message de statut
status() {
    echo -e "\n\033[1m$1\033[0m"
}

# Fonction pour vérifier si une commande a réussi
check() {
    if [ $? -eq 0 ]; then
        echo -e "\033[32m✓ $1 terminé avec succès\033[0m"
    else
        echo -e "\033[31m✗ Erreur lors de $1\033[0m"
        exit 1
    fi
}

# Mise à jour du système
status "Mise à jour du système..."
apt-get update && apt-get upgrade -y
check "Mise à jour du système"

# Installation de l'annuaire LDAP
status "Installation de l'annuaire LDAP..."
./install_ldap.sh
check "Installation de l'annuaire LDAP"

# Installation du serveur web
status "Installation du serveur web..."
./install_web.sh
check "Installation du serveur web"

# Installation du serveur de base de données
status "Installation du serveur de base de données..."
./install_db.sh
check "Installation du serveur de base de données"

# Installation du serveur de messagerie
status "Installation du serveur de messagerie..."
./install_mail.sh
check "Installation du serveur de messagerie"

# Installation du serveur de fichiers
status "Installation du serveur de fichiers..."
./install_samba.sh
check "Installation du serveur de fichiers"

# Installation du monitoring
status "Installation du monitoring..."
./install_monitoring.sh
check "Installation du monitoring"

# Configuration finale
status "Configuration finale..."
echo "Tous les services ont été installés avec succès"
echo "Voici les accès aux différents services :"
echo ""
echo "1. Portail Intranet : http://intranet.entreprise.com"
echo "2. Gestion LDAP : http://intranet.entreprise.com/phpldapadmin"
echo "3. Webmail : http://mail.entreprise.com/roundcube"
echo "4. Monitoring : http://localhost/nagios3"
echo ""
echo "Pour gérer les utilisateurs, utilisez le script manage_users.sh"
echo "Pour configurer Samba, utilisez la commande smbpasswd"
echo ""
echo "N'oubliez pas de :"
echo "- Configurer les mots de passe par défaut"
echo "- Mettre à jour les certificats SSL"
echo "- Configurer le pare-feu"
echo "- Mettre en place les sauvegardes" 