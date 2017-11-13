#!/bin/bash
. /var/lib/restic/env
df="/etc/mysql/debian.cnf"
if [[ "$1" != "" ]]; then
    df="$1"
fi

export RESTIC_REPOSITORY="${RESTIC_REPOSITORY_BASE}mysql/"
restic unlock

list=$(/usr/bin/mysqlshow --defaults-file=$df | grep -v Databases | awk '{print $2}' | grep -v -E 'performance_schema|information_schema' | sort)
for x in $list; do
    echo "Backup $x";
    /usr/bin/mysqldump --defaults-file=$df --extended-insert --create-options --disable-keys --quick --opt --hex-blob --default-character-set=utf8 $x | \
    restic -q backup --stdin --stdin-filename ${x}.sql
done;

