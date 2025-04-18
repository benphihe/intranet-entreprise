#!/bin/bash

# Script d'installation et configuration du monitoring
# Nécessite les droits root/sudo

# Mise à jour du système
apt-get update
apt-get upgrade -y

# Installation de Nagios et des plugins
apt-get install -y nagios3 nagios-nrpe-plugin nagios-plugins

# Configuration de Nagios
cat > /etc/nagios3/conf.d/localhost_nagios2.cfg <<EOF
define host {
    use                     generic-host
    host_name               localhost
    alias                   localhost
    address                 127.0.0.1
    check_command           check-host-alive
    max_check_attempts      10
    notification_interval   120
    notification_period     24x7
    notification_options    d,u,r
}

define service {
    use                     generic-service
    host_name               localhost
    service_description     PING
    check_command           check_ping!100.0,20%!500.0,60%
}

define service {
    use                     generic-service
    host_name               localhost
    service_description     HTTP
    check_command           check_http
}

define service {
    use                     generic-service
    host_name               localhost
    service_description     SSH
    check_command           check_ssh
}

define service {
    use                     generic-service
    host_name               localhost
    service_description     Disk Space
    check_command           check_nrpe!check_disk
}

define service {
    use                     generic-service
    host_name               localhost
    service_description     Current Load
    check_command           check_nrpe!check_load
}

define service {
    use                     generic-service
    host_name               localhost
    service_description     Total Processes
    check_command           check_nrpe!check_total_procs
}

define service {
    use                     generic-service
    host_name               localhost
    service_description     Current Users
    check_command           check_nrpe!check_users
}
EOF

# Configuration de NRPE
cat > /etc/nagios/nrpe.cfg <<EOF
log_facility=daemon
pid_file=/var/run/nagios/nrpe.pid
server_port=5666
nrpe_user=nagios
nrpe_group=nagios
allowed_hosts=127.0.0.1
dont_blame_nrpe=0
allow_bash_command_substitution=0
debug=0
command_timeout=60
connection_timeout=300
command[check_users]=/usr/lib/nagios/plugins/check_users -w 5 -c 10
command[check_load]=/usr/lib/nagios/plugins/check_load -w 15,10,5 -c 30,25,20
command[check_disk]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /
command[check_total_procs]=/usr/lib/nagios/plugins/check_procs -w 150 -c 200
EOF

# Redémarrage des services
systemctl restart nagios3
systemctl restart nagios-nrpe-server

# Création de l'utilisateur web pour Nagios
htpasswd -b /etc/nagios3/htpasswd.users nagiosadmin mot_de_passe

echo "Installation du monitoring terminée"
echo "L'interface web de Nagios est accessible sur http://localhost/nagios3"
echo "Identifiants Nagios :"
echo "  - Utilisateur : nagiosadmin"
echo "  - Mot de passe : mot_de_passe" 