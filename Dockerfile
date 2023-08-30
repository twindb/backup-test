FROM ubuntu:jammy
LABEL maintainer="TwinDB Development Team <dev@twindb.com>"
EXPOSE 22
EXPOSE 3306
ENV container docker

# Install packages
# Install OS dependencies
## Install MySQL server
RUN apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get -y install  \
    gnupg2 \
    curl \
    debconf \
    adduser \
    libc6 libgssapi-krb5-2 libkrb5-3 libsasl2-2 libudev1 \
    perl psmisc \
    libaio1 libmecab2 libnuma1 \
    libdbd-mysql-perl libcurl4-openssl-dev rsync libev4 \
    openssh-server \
    zstd \
    ncat \
    mysql-server mysql-client ; \
    apt-get clean

# Install Xtrabackup
RUN p=percona-xtrabackup-80_8.0.34-29-1.jammy_amd64.deb ;\
    curl -Ls https://downloads.percona.com/downloads/Percona-XtraBackup-8.0/Percona-XtraBackup-8.0.34-29/binary/debian/jammy/x86_64/$p > /tmp/$p ; \
    dpkg -i /tmp/$p; \
    rm /tmp/$p


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

COPY my-master-legacy.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

RUN systemctl set-default multi-user.target
RUN systemctl mask dev-hugepages.mount sys-fs-fuse-connections.mount

STOPSIGNAL SIGRTMIN+3
CMD ["/bin/bash", "-c", "exec /sbin/init --log-target=journal 3>&1"]
