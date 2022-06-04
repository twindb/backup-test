#!/usr/bin/env bash
DATADIR="/var/lib/mysql"
RUNDIR="/run/mysqld"

for d in ${DATADIR} ${RUNDIR}
do
    rm -rf $d
    mkdir -p $d
    /bin/chown -R mysql:mysql $d
done

/usr/bin/mysql_install_db --user=mysql
mysqld --initialize-insecure
/usr/sbin/sshd

exec /usr/sbin/mysqld
