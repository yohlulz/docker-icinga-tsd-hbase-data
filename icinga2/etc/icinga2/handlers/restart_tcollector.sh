#!/bin/sh

HOST=$1
STATE=$2
TYPE=$3
ATTEMPT=$4

echo "`whoami` $@" >> /tmp/output_restart_tcollector.txt

case "${STATE}" in
OK)
        ;;
WARNING)
        ;;
UNKNOWN)
        ;;
CRITICAL)

        case "$TYPE" in
        HARD)
                echo -n "Restarting service..."
		ssh root@${HOST} supervisorctl -c /etc/supervisord.conf restart tcollector
		sleep 150
                ;;
        esac
        ;;
esac
exit 0
