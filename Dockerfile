FROM centos:centos7
LABEL maintainer="TwinDB Development Team <dev@twindb.com>"
EXPOSE 22
EXPOSE 3306
ENV container docker

# Install packages
RUN \
    yum clean all ; \
    yum -y install  \
        epel-release ; \
    yum -y install \
        https://downloads.mysql.com/archives/get/p/23/file/mysql-community-common-5.7.37-1.el7.x86_64.rpm \
        https://downloads.mysql.com/archives/get/p/23/file/mysql-community-libs-5.7.37-1.el7.x86_64.rpm \
        https://downloads.mysql.com/archives/get/p/23/file/mysql-community-libs-compat-5.7.37-1.el7.x86_64.rpm \
        https://downloads.mysql.com/archives/get/p/23/file/mysql-community-server-5.7.37-1.el7.x86_64.rpm \
        https://downloads.mysql.com/archives/get/p/23/file/mysql-community-client-5.7.37-1.el7.x86_64.rpm \
        openssh-server \
        nmap \
        sudo \
        https://downloads.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.26/binary/redhat/7/x86_64/percona-xtrabackup-24-2.4.26-1.el7.x86_64.rpm ; \
    yum clean all ; \
    rm -rf /var/cache/yum ; \
    rm -rf /var/tmp/yum-*

# Install/start sshd
RUN \
    /usr/bin/ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -P "" ; \
    /usr/bin/ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -P "" ; \
    mkdir -p /root/.ssh/ ; \
    /bin/chown root:root /root/.ssh ; \
    /bin/chmod 700 /root/.ssh

COPY id_rsa.pub /root/.ssh/authorized_keys
RUN \
    /bin/chmod 600 /root/.ssh/authorized_keys ; \
    /bin/chown root:root /root/.ssh/authorized_keys
# Strip binaries
RUN strip /usr/sbin/mysql*
RUN ls /usr/bin/mysql* | grep -v -e mysqld_pre_systemd -e mysqldumpslow | xargs strip

# Install/start MySQL
ADD my-master-legacy.cnf /etc/my.cnf

RUN systemctl set-default multi-user.target
RUN systemctl mask dev-hugepages.mount sys-fs-fuse-connections.mount

STOPSIGNAL SIGRTMIN+3

CMD ["/bin/bash", "-c", "exec /sbin/init --log-target=journal 3>&1"]
