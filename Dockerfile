# Use Base Debian Bullseye slim image
FROM debian:bullseye-slim

# Author of this Dockerfile
LABEL org.opencontainers.image.authors="marko[AT]aretaja.org"

# Update and install fusiondirectory
RUN apt-get -qq update && \
  DEBIAN_FRONTEND=noninteractive apt-get -yqq dist-upgrade && \
  DEBIAN_FRONTEND=noninteractive apt-get -yqq install \
    apache2 \
    ldap-utils \
    fusiondirectory \
    fusiondirectory-plugin-ldapdump \
    fusiondirectory-plugin-ldapmanager \
    fusiondirectory-plugin-mail \
    fusiondirectory-plugin-mail-schema \
    fusiondirectory-plugin-samba \
    fusiondirectory-plugin-samba-schema \
    fusiondirectory-plugin-user-reminder \
    fusiondirectory-plugin-user-reminder-schema \
    fusiondirectory-schema && \
 DEBIAN_FRONTEND=noninteractive apt-get -yqq autoremove && \
 apt-get -qq clean && \
 rm -rf /var/lib/apt/lists/*

# Default env variables
ENV CONFIG_CHECK=0
ENV SVCPORT=80

# Start script
WORKDIR /home/apache2
RUN mkdir bin ldap
ADD --chown=root:root --chmod=0770 files/start.sh bin/

EXPOSE 80

ENTRYPOINT [ "./bin/start.sh" ]
