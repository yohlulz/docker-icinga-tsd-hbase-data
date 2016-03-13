#!/bin/bash

HOST=$1
STATE=$2
TYPE=$3
ATTEMPT=$4
TSD_HOST=$5
LAST_STATE=$6

echo "`whoami` $@" >> /tmp/output_tcollector.txt


function import_data {
	echo -n "Importing tsd data"
	scp root@${HOST}:/opt/data/dump/127\.0\.0\.1 /tmp/${HOST}
	scp /tmp/${HOST} root@${TSD_HOST}:/tmp/
	ssh root@${TSD_HOST} /opt/opentsdb/build/tsdb import --config /opt/data/tsdb/opentsdb.conf /tmp/${HOST}
	
	# clean
	rm /tmp/${HOST}
	ssh root@${HOST} rm /opt/data/dump/127\.0\.0\.1
}


case "${STATE}" in
OK)
	case "${LAST_STATE}" in
	CRITICAL)
		echo -n "Stopping drain service ..."
                ssh root@${HOST} supervisorctl -c /etc/supervisord.conf stop tsd_drain
		import_data
		;;
	esac
        ;;
WARNING)
        ;;
UNKNOWN)
        ;;
CRITICAL)

        case "${TYPE}" in
        HARD)
			
               	echo -n "Starting drain service ..."
		ssh root@${HOST} supervisorctl -c /etc/supervisord.conf start tsd_drain
                ;;
        esac
        ;;
esac
exit 0
