# Build image
```
docker build --network=host -t fusiondirectory_debian .
```

# Make config/log environment
```
mkdir -m 0700 -p /opt/my_containers/fusiondirectory \
  && mkdir -p /opt/my_containers/fusiondirectory/etc/fusiondirectory \
  && mkdir -p /opt/my_containers/fusiondirectory/etc/ldap \
  && mkdir -p /var/log/my_containers/fusiondirectory \
  && chown -R root:root /opt/my_containers/fusiondirectory \
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
