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

## Install MySQL server
RUN for p in \
      mysql-common_8.0.28-1ubuntu20.04_amd64.deb \
    mysql-community-client-plugins_8.0.28-1ubuntu20.04_amd64.deb \
    mysql-community-client-core_8.0.28-1ubuntu20.04_amd64.deb \
    mysql-community-client_8.0.28-1ubuntu20.04_amd64.deb \
    mysql-client_8.0.28-1ubuntu20.04_amd64.deb \
    mysql-community-server-core_8.0.28-1ubuntu20.04_amd64.deb \
    mysql-community-server_8.0.28-1ubuntu20.04_amd64.deb \
    libmysqlclient21_8.0.28-1ubuntu20.04_amd64.deb \
    ; do \
    curl -Ls https://downloads.mysql.com/archives/get/p/23/file/$p > /tmp/$p; \
    DEBIAN_FRONTEND=noninteractive dpkg -i /tmp/$p; \
    rm /tmp/$p; \
    done

# Install Xtrabackup

RUN p=percona-xtrabackup-80_8.0.28-20-1.focal_amd64.deb ;\
    curl -Ls https://downloads.percona.com/downloads/Percona-XtraBackup-LATEST/Percona-XtraBackup-8.0.28-20/binary/debian/focal/x86_64/$p > /tmp/$p ; \
    dpkg -i /tmp/$p; \
    rm /tmp/$p

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

COPY my-master-legacy.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN systemctl set-default multi-user.target
RUN systemctl mask dev-hugepages.mount sys-fs-fuse-connections.mount

STOPSIGNAL SIGRTMIN+3

CMD ["/bin/bash", "-c", "exec /sbin/init --log-target=journal 3>&1"]
