#!/bin/bash -e
. /var/lib/restic/env
if [ ! -f "/var/lib/restic/.init_$1" ]; then
    restic -r ${RESTIC_REPOSITORY_BASE}${1}/ init
    touch "/var/lib/restic/.init_$1"
fi
