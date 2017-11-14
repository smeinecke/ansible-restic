#!/bin/bash -e
. /var/lib/restic/env

df="/etc/mysql/debian.cnf"
if [[ "$2" != "" ]]; then
    df="$2"
fi

if [[ "$1" != "" ]]; then
    if [ ! -f /var/lib/restic/.xtrabackup_installed_$1 ]; then
        docker exec -i "$1" apt-get update
        docker exec -i "$1" apt-get install -y xtrabackup
        touch /var/lib/restic/.xtrabackup_installed_$1
    fi
    docker cp $df $1:/root/.my.cnf
    docker exec -i "$1" innobackupex --stream=tar --no-timestamp /tmp | \
        restic -q -r ${RESTIC_REPOSITORY_BASE}mysql/ -p $RESTIC_PASSWORD_FILE backup --stdin --stdin-filename data.tar
    docker exec -i "$1" rm /root/.my.cnf
else
    innobackupex --defaults-file=$df --stream=tar --no-timestamp /tmp | \
        restic -q -r ${RESTIC_REPOSITORY_BASE}mysql/ -p $RESTIC_PASSWORD_FILE backup --stdin --stdin-filename data.tar
fi
