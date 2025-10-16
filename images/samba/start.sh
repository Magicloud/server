#!/bin/sh
[ -n "${1}" ] && chmod 777 "${1}"
ionice -c 3 /usr/sbin/smbd -FS --no-process-group < /dev/null
