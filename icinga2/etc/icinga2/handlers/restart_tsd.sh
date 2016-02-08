#!/bin/sh

HOST=$1
STATE=$2
TYPE=$3
ATTEMPT=$4

echo "`whoami` $@" >> /tmp/output.txt

case "${STATE}" in
OK)
        ;;
WARNING)
        ;;
UNKNOWN)
        ;;
CRITICAL)

        case "$TYPE" in
        SOFT)
                        
                case "${ATTEMPT}" in                
                6)
                        echo -n "Restarting service (3rd soft critical state)..."
			ssh root@${HOST} supervisorctl -c /etc/supervisord.conf restart opentsdb
                        ;;
		esac
                ;;
                                
        HARD)
                echo -n "Restarting service..."
		ssh root@${HOST} supervisorctl -c /etc/supervisord.conf restart opentsdb
                ;;
        esac
        ;;
esac
exit 0
