# Guide Utilisateur de l'Intranet d'Entreprise

## Table des matières
1. [Introduction](#introduction)
2. [Accès aux services](#accès-aux-services)
3. [Gestion des utilisateurs](#gestion-des-utilisateurs)
4. [Partage de fichiers](#partage-de-fichiers)
5. [Messagerie](#messagerie)
6. [Monitoring](#monitoring)
7. [Maintenance](#maintenance)

## Introduction

Ce guide explique comment utiliser et maintenir l'intranet d'entreprise. L'intranet comprend plusieurs services :
- Un annuaire LDAP pour la gestion des utilisateurs
- Un serveur web avec portail d'accès
- Un serveur de messagerie
- Un serveur de fichiers
- Un système de monitoring

## Accès aux services

### Portail Intranet
- URL : http://intranet.entreprise.com
- Fonctionnalités :
  - Accès centralisé à tous les services
  - Tableau de bord personnalisé
  - Liens rapides vers les applications

### Gestion LDAP
- URL : http://intranet.entreprise.com/phpldapadmin
- Accès réservé aux administrateurs
- Permet de gérer les utilisateurs et les groupes

### Webmail
- URL : http://mail.entreprise.com/roundcube
- Fonctionnalités :
  - Consultation des emails
  - Gestion des contacts
  - Agenda partagé

## Gestion des utilisateurs

### Création d'un utilisateur
1. Se connecter à phpLDAPadmin
2. Naviguer vers "ou=people"
3. Cliquer sur "Create new entry"
4. Sélectionner "Generic: User Account"
5. Remplir les informations :
   - uid (nom d'utilisateur)
   - cn (nom complet)
   - sn (nom de famille)
   - givenName (prénom)
   - userPassword (mot de passe)

### Modification d'un utilisateur
1. Se connecter à phpLDAPadmin
2. Naviguer vers l'utilisateur
3. Modifier les attributs souhaités
4. Sauvegarder les modifications

### Suppression d'un utilisateur
1. Se connecter à phpLDAPadmin
2. Naviguer vers l'utilisateur
3. Cliquer sur "Delete"
4. Confirmer la suppression

## Partage de fichiers

### Accès aux partages
- Windows : `\\serveur\share`
- Linux : `smb://serveur/share`
- Mac : `smb://serveur/share`

### Droits d'accès
- Les utilisateurs doivent appartenir au groupe "sambashare"
- Les droits sont gérés par l'administrateur système

## Messagerie

### Configuration du client mail
- Serveur IMAP : mail.entreprise.com
- Port : 143 (IMAP) ou 993 (IMAPS)
- Serveur SMTP : mail.entreprise.com
- Port : 25 (SMTP) ou 587 (SMTPS)

### Webmail
- Interface web complète
- Gestion des dossiers
- Filtres de messages
- Carnet d'adresses

## Monitoring

### Accès au monitoring
- URL : http://localhost/nagios3
- Identifiants :
  - Utilisateur : nagiosadmin
  - Mot de passe : [à configurer]

### Surveillance des services
- État des services en temps réel
- Alertes par email
- Historique des incidents

## Maintenance

### Sauvegardes
- Sauvegarde quotidienne des données
- Rotation des sauvegardes sur 30 jours
- Test de restauration mensuel

### Mises à jour
- Mises à jour de sécurité automatiques
- Mises à jour majeures planifiées
- Fenêtre de maintenance : samedi 2h-4h

### Procédures d'urgence
1. Identifier le problème via Nagios
2. Consulter les logs
3. Appliquer les correctifs
4. Documenter l'incident

## Support

Pour toute assistance :
- Support technique : support@entreprise.com
- Urgences : +33 1 23 45 67 89
- Documentation en ligne : http://intranet.entreprise.com/docs 