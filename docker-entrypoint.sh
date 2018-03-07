#!/usr/bin/env bash
DATADIR="/var/lib/mysql"

function clean_datadir() {
    /bin/rm -rf /var/lib/mysql/*
}

clean_datadir
exec /usr/sbin/sshd -D


