#!/usr/bin/env bash

set -eu
DATADIR="/var/lib/mysql"

/usr/sbin/mysqld --initialize-insecure
/bin/chown -R mysql:mysql "${DATADIR}" /var/run/mysqld
/bin/chmod 777 /var/run/mysqld
/usr/sbin/sshd

exec /usr/sbin/mysqld
