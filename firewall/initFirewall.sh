#!/bin/sh
#
# $Id: initFirewall.sh,v 1.2 2002/01/07 20:31:15 racon Exp $
#
# This script initializes the firewall, so that it could be used by the
# DHCP registration system. It will call all the scripts located in the
# 'init.d' directory. These scripts will create the several targets in the
# firewall tables.

if test -z "`echo $0 |grep \"^\/\"`" ; then
    BASE=`echo "\`pwd\`/$0" | sed -e "s/\/[^\/]*$/\/../g"`
else
    BASE=`echo $0 | sed -e "s/\/[^\/]*$/\/../g"`
fi

. $BASE/etc/bridge-fw.conf

###########
# MAIN PART

if test -d $BASE/firewall/init.d ; then
    for I in `ls -1 $BASE/firewall/init.d/script[0-9][0-9]*` ; do
        echo "Executing firewall init script $I:"
        sh $I ;
        if test $? != 0 ; then
            echo "Execution of firewall init script '$I' failed." 
        fi
    done
fi

exit 0
