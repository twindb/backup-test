#!/usr/bin/env bash
DATADIR="/var/lib/mysql"

mysqld --initialize-insecure
/bin/chown -R mysql:mysql "${DATADIR}" /var/run/mysqld
/bin/chmod 777 /var/run/mysqld

exec mysqld