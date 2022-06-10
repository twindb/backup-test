FROM ubuntu:focal
LABEL maintainer="TwinDB Development Team <dev@twindb.com>"
EXPOSE 22
EXPOSE 3306
ENV container docker

# Install OS dependencies
RUN apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get -y install  \
    gnupg2 \
    curl \
    debconf \
    adduser \
    libc6 libgcc-s1 libgssapi-krb5-2 libkrb5-3 libsasl2-2 libssl1.1 libstdc++6 libudev1 \
    perl psmisc \
    libaio1 libmecab2 libnuma1 \
    libdbd-mysql-perl libcurl4-openssl-dev rsync libev4 \
    openssh-server; \
    apt-get clean

## Install MariaDB server and mariadb-backup
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
    mariadb-server \
    mariadb-client \
    mariadb-backup; \
    apt-get clean

RUN /usr/bin/mysql_install_db --user=mysql
RUN /bin/chown -R mysql:mysql /var/lib/mysql

# Install/start sshd
RUN \
    mkdir /var/run/sshd ; \
    mkdir -p /root/.ssh/ ; \
    /bin/chown root:root /root/.ssh ; \
    /bin/chmod 700 /root/.ssh

COPY id_rsa.pub /root/.ssh/authorized_keys
RUN \
    /bin/chmod 600 /root/.ssh/authorized_keys ; \
    /bin/chown root:root /root/.ssh/authorized_keys

COPY my-master-legacy.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN systemctl set-default multi-user.target
RUN systemctl mask dev-hugepages.mount sys-fs-fuse-connections.mount

STOPSIGNAL SIGRTMIN+3

CMD ["/bin/bash", "-c", "exec /sbin/init --log-target=journal 3>&1"]
