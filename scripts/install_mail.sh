#!/bin/bash

# Script d'installation et configuration du serveur de messagerie
# Nécessite les droits root/sudo

# Mise à jour du système
apt-get update
apt-get upgrade -y

# Installation des paquets nécessaires
apt-get install -y postfix dovecot-imapd dovecot-pop3d dovecot-ldap roundcube roundcube-plugins

# Configuration de Postfix
cat > /etc/postfix/main.cf <<EOF
myhostname = mail.entreprise.com
mydomain = entreprise.com
myorigin = \$mydomain
mydestination = \$myhostname, localhost.\$mydomain, localhost, \$mydomain
mynetworks = 127.0.0.0/8
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = all
inet_protocols = all
home_mailbox = Maildir/
mailbox_command =
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_auth_enable = yes
smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination
EOF

# Configuration de Dovecot
cat > /etc/dovecot/conf.d/10-auth.conf <<EOF
disable_plaintext_auth = no
auth_mechanisms = plain login
!include auth-ldap.conf.ext
EOF

cat > /etc/dovecot/conf.d/auth-ldap.conf.ext <<EOF
passdb {
  driver = ldap
  args = /etc/dovecot/dovecot-ldap.conf.ext
}
userdb {
  driver = ldap
  args = /etc/dovecot/dovecot-ldap.conf.ext
}
EOF

cat > /etc/dovecot/dovecot-ldap.conf.ext <<EOF
hosts = localhost
dn = cn=admin,dc=entreprise,dc=com
dnpass = votre_mot_de_passe_ldap
auth_bind = yes
ldap_version = 3
base = ou=people,dc=entreprise,dc=com
user_attrs = homeDirectory=home,uidNumber=uid,gidNumber=gid
user_filter = (&(objectClass=posixAccount)(uid=%u))
pass_attrs = uid=user,userPassword=password
pass_filter = (&(objectClass=posixAccount)(uid=%u))
EOF

# Configuration de Roundcube
cat > /etc/roundcube/config.inc.php <<EOF
<?php
\$config = array();
\$config['db_dsnw'] = 'mysql://roundcube:mot_de_passe@localhost/roundcubemail';
\$config['default_host'] = 'localhost';
\$config['default_port'] = 143;
\$config['smtp_server'] = 'localhost';
\$config['smtp_port'] = 25;
\$config['smtp_user'] = '%u';
\$config['smtp_pass'] = '%p';
\$config['support_url'] = '';
\$config['product_name'] = 'Webmail Entreprise';
\$config['plugins'] = array('archive', 'zipdownload');
EOF

# Redémarrage des services
systemctl restart postfix
systemctl restart dovecot
systemctl restart apache2

echo "Installation du serveur de messagerie terminée"
echo "Le webmail est accessible sur http://mail.entreprise.com/roundcube" 