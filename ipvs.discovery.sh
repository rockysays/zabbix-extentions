#!/usr/bin/env bash
# Description:  keepalived services auto-discovery
# Author:       Maksim Klyushkov <m.klyushkov@trige.ru>
# Setup:        Zabbix user need access to run "sudo ipvsadm".
#               Add "zabbix  ALL=NOPASSWD: /sbin/ipvsadm" to /etc/sudoers file.
#               And delete line "Defaults requiretty".
#               Also, zabbix need permisions to write in $FILE.

FILE=/tmp/discovered
SERVICES=`sudo ipvsadm -Ln | grep TCP | awk '{ print $2 }'`

> $FILE

for service in $SERVICES; do
        echo $service >> $FILE
        for backend in `sudo ipvsadm -Ln -t $service | tail -n +4 | awk '{ print $2}'`; do
                 echo $service $backend >> $FILE
        done
#echo $service `sudo ipvsadm -Ln -t $service | tail -n +4 | awk '{ print $2}'`;
done

COUNT=`cat $FILE | wc -l`
COUNTER=1
IFS=$'\n'

echo -n '{"data":['
for i in `cat $FILE`; do
        if [ "$COUNTER" -lt "$COUNT" ]
        then
                echo -n "{\"{#IPVS}\": \"$i\"},"
        else
                echo -n "{\"{#IPVS}\": \"$i\"}"
        fi
        ((COUNTER++))
done
echo -n ']}'