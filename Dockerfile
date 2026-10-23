# Use Base Debian Bullseye slim image
FROM debian:bullseye-slim

ARG APP_UID=10001
ARG APP_GID=10001
ARG APP_NAME=fusiondir
ARG SHARED_GID=20000
ARG SHARED_NAME=containers

# Author of this Dockerfile
LABEL org.opencontainers.image.authors="marko[AT]aretaja.org"

# Update and install fusiondirectory
RUN printf '%s\n' \
      'deb http://archive.debian.org/debian bullseye main' \
      'deb http://archive.debian.org/debian bullseye-updates main' \
      'deb http://archive.debian.org/debian-security bullseye-security main' \
      > /etc/apt/sources.list \
  && echo 'Acquire::Check-Valid-Until "false";' \
      > /etc/apt/apt.conf.d/99archive \
  && apt-get -qq update \
  && DEBIAN_FRONTEND=noninteractive apt-get -yqq dist-upgrade \
  && DEBIAN_FRONTEND=noninteractive apt-get -yqq install \
    apache2 \
    ldap-utils \
    mailutils \
    msmtp-mta \
    fusiondirectory \
    fusiondirectory-plugin-ldapdump \
    fusiondirectory-plugin-ldapmanager \
    fusiondirectory-plugin-mail \
    fusiondirectory-plugin-mail-schema \
    fusiondirectory-plugin-samba \
    fusiondirectory-plugin-samba-schema \
    fusiondirectory-plugin-user-reminder \
    fusiondirectory-plugin-user-reminder-schema \
    fusiondirectory-schema \
  && DEBIAN_FRONTEND=noninteractive apt-get -yqq autoremove \
  && apt-get -qq clean \
  && rm -rf /var/lib/apt/lists/* \
  && groupadd -g ${APP_GID} ${APP_NAME} \
  && groupadd -g ${SHARED_GID} ${SHARED_NAME} \
  && useradd -u ${APP_UID} -g ${APP_GID} -d /home/apache2 -s /bin/sh ${APP_NAME} \
  && usermod -a -G ${SHARED_NAME} ${APP_NAME} \
  && mkdir -p \
    /home/apache2/bin \
    /home/apache2/ldap \
    /var/log/apache2 \
    /var/run/apache2 \
    /var/lock/apache2 \
    /var/lib/apache2 \
    /var/cache/apache2 \
  && touch /etc/msmtprc \
    /etc/aliases \
  && chown -R ${APP_NAME}:${APP_NAME} \
    /etc/apache2 \
    /etc/ldap \
    /home/apache2 \
    /var/log/apache2 \
    /var/run/apache2 \
    /var/lock/apache2 \
    /var/lib/apache2 \
    /var/cache/apache2 \
    /var/cache/fusiondirectory \
    /var/spool/fusiondirectory \
    /etc/msmtprc \
    /etc/aliases

# Default env variables
ENV CONFIG_CHECK=0
ENV APACHE_RUN_USER=${APP_NAME}
ENV APACHE_RUN_GROUP=${APP_NAME}
ENV APACHE_PID_FILE=/var/run/apache2/apache2.pid
ENV APACHE_RUN_DIR=/var/run/apache2
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_LOG_DIR=/var/log/apache2
ENV SMTP_MAILROOT=root
ENV SMTP_MAILHUB=smtp.isp.fqn
ENV SMTP_PORT=25
ENV SMTP_MAILDOMAIN=myhost.isp.fqn
ENV SMTP_MAILHOST=myhost.isp.fqn
ENV SMTP_MAILFROMDOMAIN=isp.fqn

# Start script
WORKDIR /home/apache2
ADD --chown=${APP_NAME}:${APP_NAME} --chmod=0770 files/start.sh bin/
ADD files/hp_uploadprogress_guard-7.4.ini /etc/php/7.4/apache2/conf.d/05-hp_uploadprogress_guard-7.4.ini
ADD files/hp_uploadprogress_guard-7.4.so /usr/lib/php/20190902/hp_uploadprogress_guard-7.4.so

EXPOSE 2180

USER ${APP_NAME}
ENTRYPOINT [ "./bin/start.sh" ]
