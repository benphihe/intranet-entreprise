#!/bin/bash

# Script de configuration du portail captif
# Nécessite les droits root/sudo

# Configuration
PORTAL_DIR="/var/www/captive"
LOG_FILE="/var/log/captive_portal.log"

# Fonction pour logger
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Vérification de l'installation des paquets nécessaires
log "Installation des paquets nécessaires..."
apt-get update
apt-get install -y apache2 php php-ldap iptables dnsmasq hostapd

# Configuration du portail
log "Configuration du portail captif..."
mkdir -p $PORTAL_DIR
cat > $PORTAL_DIR/index.php <<EOF
<?php
session_start();

// Configuration LDAP
\$ldap_server = "ldap://localhost";
\$ldap_dn = "dc=entreprise,dc=com";
\$ldap_user = "cn=admin,\$ldap_dn";
\$ldap_pass = "mot_de_passe_admin";

if (\$_SERVER['REQUEST_METHOD'] === 'POST') {
    \$username = \$_POST['username'];
    \$password = \$_POST['password'];
    
    // Connexion LDAP
    \$ldap = ldap_connect(\$ldap_server);
    ldap_set_option(\$ldap, LDAP_OPT_PROTOCOL_VERSION, 3);
    
    if (\$ldap) {
        \$bind = @ldap_bind(\$ldap, "uid=\$username,ou=people,\$ldap_dn", \$password);
        
        if (\$bind) {
            // Authentification réussie
            \$_SESSION['authenticated'] = true;
            \$_SESSION['username'] = \$username;
            
            // Redirection vers la page de succès
            header("Location: success.php");
            exit;
        } else {
            \$error = "Identifiants incorrects";
        }
    } else {
        \$error = "Erreur de connexion au serveur LDAP";
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Portail Captif - Authentification</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f0f0f0;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .login-box {
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            width: 300px;
        }
        h1 {
            text-align: center;
            color: #333;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
        }
        input {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 3px;
        }
        button {
            width: 100%;
            padding: 10px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 3px;
            cursor: pointer;
        }
        .error {
            color: red;
            text-align: center;
            margin-bottom: 15px;
        }
    </style>
</head>
<body>
    <div class="login-box">
        <h1>Authentification</h1>
        <?php if (isset(\$error)): ?>
            <div class="error"><?php echo \$error; ?></div>
        <?php endif; ?>
        <form method="POST">
            <div class="form-group">
                <label for="username">Nom d'utilisateur</label>
                <input type="text" id="username" name="username" required>
            </div>
            <div class="form-group">
                <label for="password">Mot de passe</label>
                <input type="password" id="password" name="password" required>
            </div>
            <button type="submit">Se connecter</button>
        </form>
    </div>
</body>
</html>
EOF

cat > $PORTAL_DIR/success.php <<EOF
<?php
session_start();
if (!isset(\$_SESSION['authenticated']) || !\$_SESSION['authenticated']) {
    header("Location: index.php");
    exit;
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Authentification réussie</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f0f0f0;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .success-box {
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            text-align: center;
        }
        h1 {
            color: #4CAF50;
        }
    </style>
</head>
<body>
    <div class="success-box">
        <h1>Authentification réussie</h1>
        <p>Bienvenue <?php echo htmlspecialchars(\$_SESSION['username']); ?> !</p>
        <p>Vous pouvez maintenant accéder à Internet.</p>
    </div>
</body>
</html>
EOF

# Configuration d'Apache
log "Configuration d'Apache..."
cat > /etc/apache2/sites-available/captive.conf <<EOF
<VirtualHost *:80>
    ServerName captive.entreprise.com
    DocumentRoot $PORTAL_DIR
    
    <Directory $PORTAL_DIR>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/captive-error.log
    CustomLog \${APACHE_LOG_DIR}/captive-access.log combined
</VirtualHost>
EOF

a2ensite captive.conf
systemctl restart apache2

# Configuration du pare-feu
log "Configuration du pare-feu..."
# Redirection du trafic HTTP vers le portail
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.1.1:80
# Autorisation du trafic authentifié
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp --dport 80 -d 192.168.1.1 -j ACCEPT
iptables -A FORWARD -j REJECT

# Configuration de dnsmasq
log "Configuration de dnsmasq..."
cat > /etc/dnsmasq.conf <<EOF
interface=wlan0
dhcp-range=192.168.1.100,192.168.1.200,12h
dhcp-option=3,192.168.1.1
dhcp-option=6,8.8.8.8,8.8.4.4
address=/#/192.168.1.1
EOF

# Configuration de hostapd
log "Configuration de hostapd..."
cat > /etc/hostapd/hostapd.conf <<EOF
interface=wlan0
driver=nl80211
ssid=Entreprise-Guest
hw_mode=g
channel=6
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=MotDePasseGuest
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

# Démarrage des services
log "Démarrage des services..."
systemctl restart dnsmasq
systemctl restart hostapd

log "Configuration du portail captif terminée avec succès"
echo "Le portail captif est accessible sur http://captive.entreprise.com"
exit 0 