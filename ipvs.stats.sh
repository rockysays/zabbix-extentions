#!/usr/bin/env bash
# Description:  Parsing ipvsadm stats
# Author:       Maksim Klyushkov <m.klyushkov@trige.ru>
# Setup:        Zabbix user need access to run "sudo ipvsadm".
#               Add "zabbix  ALL=NOPASSWD: /sbin/ipvsadm" to /etc/sudoers file.
#               And delete line "Defaults requiretty".

#SERVICE=`echo $2 | awk '{ print $1 }'`
#BACKEND=`echo $2 | awk '{ print $2 }'`

SERVICE=$2
BACKEND=$3

METRIC=0


case "$1" in
"Conns")
        NUMBER=3
;;
"InPkts")
        NUMBER=4
;;
"OutPkts")
        NUMBER=5
;;
"InBPS")
        NUMBER=6
;;
"OutBPS")
        NUMBER=7
;;
*) echo ZBX_NOTSUPPORTED; exit 1 ;;
esac

if [ -z "$BACKEND" ]; then
        sudo ipvsadm -Ln --rate | grep $SERVICE | awk -v stats=$NUMBER '{ print $stats }'
else
        sudo ipvsadm -Ln -t $SERVICE --rate | grep $BACKEND | awk -v stats=$NUMBER '{ print $stats }'
fi