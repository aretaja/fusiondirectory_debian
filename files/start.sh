#!/bin/sh
chown -R www-data /var/log/apache2

# apache2 config
echo "Preparing webserver config"
echo Listen 127.0.0.1:${SVCPORT} >/etc/apache2/ports.conf

cat >/etc/apache2/sites-enabled/000-default.conf<<EOF
ServerName localhost
<VirtualHost *:${SVCPORT}>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    DirectoryIndex index.html index.php
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# LDAP config
echo "Preparing ldap config"
if [ -e ./ldap/*.pem ]; then
    echo "Importing ldap certificates"
    cp -a ./ldap/*.pem /etc/ldap/
fi
if [ -e ./ldap/*.conf ]; then
    echo "Importing ldap config file"
    cp -a ./ldap/*.conf /etc/ldap/
fi

# start apache2
echo "Start webserver"
if  [ "${CONFIG_CHECK}" -eq 1 ]; then
    /usr/sbin/apache2ctl configtest
else
    /usr/sbin/apache2ctl -D FOREGROUND
fi
