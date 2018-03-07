#!/usr/bin/env bash

function clean_datadir() {
    /bin/rm -rf /var/lib/mysql/*
}

clean_datadir
exec /usr/sbin/sshd -D