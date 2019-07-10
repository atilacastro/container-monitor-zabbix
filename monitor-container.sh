#!/bin/bash

# Vars
CONTAINERLIST=$(docker ps -a --format "{{.Names}}" > "/tmp/zabbix_monitor/listacontainer")
CONTAINERS=$(cat /tmp/zabbix_monitor/listacontainer)
CONTAINERS=${CONTAINERS}
LEN=$(cat /tmp/zabbix_monitor/listacontainer | wc -l)
#LEN=${#CONTAINERS[@]}
DATA=$(date +"%d_%m_%H:%M:%S")
LOG="/var/log/zabbix/execution_log_monitor_container.log"
DIREXIST=$(ls /tmp/zabbix_monitor | wc -l)
counter=0

echo "$DATA - START LOG" >> $LOG

if [ "$DIREXIST" -eq "0" ];
  then
	# Create Log file and change own and permitions
	touch /var/log/zabbix/execution_log_monitor_container.log
	chmod 775 -R /var/log/zabbix/execution_log_monitor_container.log
	chown zabbix:zabbix /var/log/zabbix/execution_log_monitor_container.log
	echo "Create Log file and change own and permitions" >> $LOG
   	# Create container list file and change own and permitions
	mkdir -p /tmp/zabbix_monitor/
	chmod 775 -R /tmp/zabbix_monitor
	chown zabbix:zabbix /tmp/zabbix_monitor
	touch /tmp/zabbix_monitor/listacontainer
	chmod 775 -R /tmp/zabbix_monitor/*
	chown zabbix:zabbix /tmp/zabbix_monitor/*
	echo "Create container list file and change own and permitions" >> $LOG
fi
for LINE in ${CONTAINERS[@]}; do
CONTAINERSTATUS=$(docker ps -a --format "{{.Status}} - {{.Names}}" | grep $LINE | awk '{print $1}' | grep Up | wc -l)

if [ "$CONTAINERSTATUS" -ge "1" ];
  then
        counter=$((counter+1)) >> $LOG
        echo $LINE " Up " >> $LOG
elif [ "$CONTAINERSTATUS" -eq "0" ];
  then
        echo $LINE " Down, restating... " >> $LOG
        docker restart $LINE >> $LOG
fi
done
if [ "$counter" -eq "$LEN" ];
  then
        echo "0"
else
        echo "1"
fi

echo "Total Containers =  $LEN" >> $LOG

echo "$DATA - FINISH LOG" >> $LOG