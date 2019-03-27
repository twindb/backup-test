FROM ubuntu:bionic
LABEL maintainer="TwinDB Development Team <dev@twindb.com>"
EXPOSE 22
EXPOSE 3306

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install packages
RUN \
    apt-get update; \
    apt-get -y install curl lsb-release wget nmap sudo net-tools \
        openssh-client openssh-server \
        python \
        gnupg

# Install Oracle Repo
RUN mysql_repo=mysql-apt-config_0.8.12-1_all.deb ; \
    curl --location https://dev.mysql.com/get/${mysql_repo} > /tmp/${mysql_repo} ; \
    debconf-set-selections <<< "mysql-apt-config    mysql-apt-config/select-server    select    mysql-5.7" ; \
    DEBIAN_FRONTEND=noninteractive dpkg -i /tmp/${mysql_repo} ; \
    apt-get update

# Clean datadir
RUN \
    /bin/rm -rf /var/lib/mysql/*

# Install/start sshd
RUN \
    mkdir /var/run/sshd ; \
    mkdir -p /root/.ssh/ ; \
    /bin/chown root:root /root/.ssh ; \
    /bin/chmod 700 /root/.ssh/ ; \
    /usr/sbin/sshd

COPY id_rsa.pub /root/.ssh/authorized_keys
RUN \
    /bin/chmod 600 /root/.ssh/authorized_keys ; \
    /bin/chown root:root /root/.ssh/authorized_keys

# Install/start MySQL
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get -y install mysql-community-server mysql-community-client

COPY my-master-legacy.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

COPY docker-entrypoint.sh /usr/local/bin/
RUN /bin/chmod 755 /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["usr/sbin/sshd", "-D"]
