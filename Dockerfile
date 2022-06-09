FROM ubuntu:focal
LABEL maintainer="TwinDB Development Team <dev@twindb.com>"
EXPOSE 22
EXPOSE 3306

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

# Clean datadir
RUN \
    /bin/rm -rf /var/lib/mysql/*

# Install sshd
RUN \
    mkdir /var/run/sshd ; \
    mkdir -p /root/.ssh/ ; \
    /bin/chown root:root /root/.ssh ; \
    /bin/chmod 700 /root/.ssh/
#
COPY id_rsa.pub /root/.ssh/authorized_keys
RUN \
    /bin/chmod 600 /root/.ssh/authorized_keys ; \
    /bin/chown root:root /root/.ssh/authorized_keys

RUN ln -s /usr/bin/python3 /usr/bin/python

COPY my-master-legacy.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY docker-entrypoint.sh /usr/local/bin/

RUN /bin/chmod 755 /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["usr/sbin/sshd", "-D"]
