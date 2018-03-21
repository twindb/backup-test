FROM centos:centos7
LABEL maintainer="TwinDB Development Team <dev@twindb.com>"
EXPOSE 22
EXPOSE 3306

# Install packages
RUN \
    yum clean all ; \
    yum -y install epel-release ; \
    yum -y install "https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm"

RUN \
    yum -y install \
    mysql-community-server \
    mysql-community-client \
    openssh-server \
    nmap \
    sudo

# Install/start sshd
RUN \
    /usr/bin/ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -P "" ; \
    /usr/bin/ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -P "" ; \
    mkdir -p /root/.ssh/ ; \
    /bin/chown root:root /root/.ssh ; \
    /bin/chmod 700 /root/.ssh/ ; \
    /usr/sbin/sshd

COPY id_rsa.pub /root/.ssh/authorized_keys
RUN \
    /bin/chmod 600 /root/.ssh/authorized_keys ; \
    /bin/chown root:root /root/.ssh/authorized_keys

# Install/start MySQL
ADD my-master-legacy.cnf /etc/my.cnf

COPY docker-entrypoint.sh /usr/local/bin/
RUN /bin/chmod 755 /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["mysqld"]
