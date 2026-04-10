# Build image
```
docker build -t aretaja/fusiondirectory_debian:20260410 .
```

# Make config/log environment
```
addgroup --gid 20000 containers
mkdir -m 2750 -p /opt/my_containers/fusiondirectory \
  && chown -R root:containers /opt/my_containers/fusiondirectory \
  && mkdir -p /opt/my_containers/fusiondirectory/etc/fusiondirectory \
  && mkdir -p /opt/my_containers/fusiondirectory/etc/ldap \
  && mkdir -m 2770 -p /var/log/my_containers/fusiondirectory \
  && chown -R root:containers /var/log/my_containers/fusiondirectory \
  && cp contrib/docker-compose.yml.example /opt/my_containers/fusiondirectory/docker-compose.yml
```

# Configure logrotate
```
cat >>/etc/logrotate.d/my_containers
/var/log/my_containers/fusiondirectory/*.log {
        weekly
        missingok
        rotate 52
        copytruncate
        compress
        delaycompress
        notifempty
        create 640 root adm
}
```
# LDAP certs
Populate `/opt/my_containers/fusiondirectory/etc/ldap` directory with ldap servers certificate pem and `ldap.conf` config file.

# Fusiondirectory
Populate `/opt/my_containers/fusiondirectory/etc/fusiondirectory` directory with config files.
