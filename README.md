# Intranet d'Entreprise

## Architecture du Projet

### Composants Principaux

1. **Annuaire LDAP (OpenLDAP)**
   - Gestion centralisée des utilisateurs
   - Authentification unique
   - Gestion des groupes

2. **Services Web**
   - Serveur Web (Apache/Nginx)
   - Portail d'accès unifié
   - Interface de gestion des utilisateurs

3. **Services de Messagerie**
   - Serveur Mail (Postfix/Dovecot)
   - Webmail (Roundcube)

4. **Partage de Fichiers**
   - Serveur Samba
   - Interface web de gestion des fichiers

5. **Base de Données**
   - Serveur MySQL/MariaDB isolé
   - Stockage des données des applications

6. **Sécurité**
   - Portail captif (PFSense)
   - VPN (OpenVPN)
   - Monitoring des logs

### Prérequis

- Système d'exploitation : Ubuntu Server 22.04 LTS
- Mémoire RAM : 8 Go minimum
- Espace disque : 100 Go minimum
- Accès root/sudo

### Installation

Les scripts d'installation se trouvent dans le dossier `scripts/`

### Configuration

Les fichiers de configuration se trouvent dans le dossier `config/`

### Documentation

La documentation détaillée se trouve dans le dossier `documentation/`

## Plan d'Implémentation

1. Installation et configuration de l'annuaire LDAP
2. Mise en place du serveur web et du portail
3. Configuration des services de messagerie
4. Installation du serveur de fichiers
5. Configuration de la base de données
6. Mise en place des services de sécurité
7. Tests et validation 