#!/usr/bin/env bash
DATADIR="/var/lib/mysql"

rm -rf ${DATADIR}
mkdir -p ${DATADIR}

mysqld --initialize-insecure --user=root
/bin/chown -R mysql:mysql "${DATADIR}" /var/run/mysqld
/bin/chmod 777 /var/run/mysqld

exec mysqld --user=root