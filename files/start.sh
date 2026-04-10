#!/bin/sh
set -eu

# apache2 config
echo "Preparing webserver config"
cat >/etc/apache2/ports.conf <<EOF
Listen 2180
EOF

cat >/etc/apache2/sites-enabled/000-default.conf<<EOF
ServerName localhost
<VirtualHost _default_:*>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    DirectoryIndex index.html index.php
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# LDAP config
echo "Preparing ldap config"
if ls ./ldap/*.pem >/dev/null 2>&1; then
    echo "Importing ldap certificates"
    cp -a ./ldap/*.pem /etc/ldap/
fi
if ls ./ldap/*.conf >/dev/null 2>&1; then
    echo "Importing ldap config file"
    cp -a ./ldap/*.conf /etc/ldap/
fi

# Setup msmtp config
cat >/etc/msmtprc<<EOF
defaults
account default
tls on
tls_starttls on
host ${SMTP_MAILHUB}
port ${SMTP_PORT}
domain ${SMTP_MAILDOMAIN}
from no-replay.useradmin@${SMTP_MAILFROMDOMAIN}
set_from_header on
aliases /etc/aliases
EOF

cat >/etc/aliases<<EOF
default: ${SMTP_MAILROOT}
EOF

# start apache2
echo "Start webserver"
if  [ "${CONFIG_CHECK}" -eq 1 ]; then
    /usr/sbin/apache2ctl configtest
else
    /usr/sbin/apache2ctl -D FOREGROUND
fi
