#!/bin/bash

# Script de gestion des utilisateurs LDAP
# Nécessite les droits root/sudo

# Variables de configuration
LDAP_DOMAIN="dc=entreprise,dc=com"
LDAP_ADMIN="cn=admin,$LDAP_DOMAIN"
LDAP_PASSWORD="votre_mot_de_passe" # À modifier avec le mot de passe réel

# Fonction pour créer un utilisateur
create_user() {
    echo "Création d'un nouvel utilisateur"
    echo "Nom d'utilisateur :"
    read USERNAME
    echo "Prénom :"
    read FIRSTNAME
    echo "Nom :"
    read LASTNAME
    echo "Mot de passe :"
    read -s PASSWORD

    # Génération du hash du mot de passe
    PASSWORD_HASH=$(slappasswd -s "$PASSWORD")

    # Création du fichier LDIF
    cat > /tmp/user.ldif <<EOF
dn: uid=$USERNAME,ou=people,$LDAP_DOMAIN
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: top
cn: $FIRSTNAME $LASTNAME
sn: $LASTNAME
givenName: $FIRSTNAME
uid: $USERNAME
uidNumber: $(($(ldapsearch -x -b "ou=people,$LDAP_DOMAIN" uidNumber | grep uidNumber | cut -d: -f2 | sort -n | tail -1) + 1))
gidNumber: 100
homeDirectory: /home/$USERNAME
userPassword: $PASSWORD_HASH
EOF

    # Ajout de l'utilisateur
    ldapadd -x -D "$LDAP_ADMIN" -w "$LDAP_PASSWORD" -f /tmp/user.ldif
    echo "Utilisateur $USERNAME créé avec succès"
}

# Fonction pour supprimer un utilisateur
delete_user() {
    echo "Suppression d'un utilisateur"
    echo "Nom d'utilisateur à supprimer :"
    read USERNAME

    ldapdelete -x -D "$LDAP_ADMIN" -w "$LDAP_PASSWORD" "uid=$USERNAME,ou=people,$LDAP_DOMAIN"
    echo "Utilisateur $USERNAME supprimé avec succès"
}

# Fonction pour lister les utilisateurs
list_users() {
    echo "Liste des utilisateurs :"
    ldapsearch -x -b "ou=people,$LDAP_DOMAIN" "(objectClass=inetOrgPerson)" | grep "uid:"
}

# Menu principal
while true; do
    echo "
Gestion des utilisateurs LDAP
1. Créer un utilisateur
2. Supprimer un utilisateur
3. Lister les utilisateurs
4. Quitter
"
    read -p "Choix : " CHOICE

    case $CHOICE in
        1) create_user ;;
        2) delete_user ;;
        3) list_users ;;
        4) exit 0 ;;
        *) echo "Choix invalide" ;;
    esac
done 