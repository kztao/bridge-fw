#!/bin/sh
#
# $Id: disableTarget.sh,v 1.1 2002/01/06 21:39:08 racon Exp $
#
# disables a target for packages for and from a specific host.
#
# Copyright (C) 2001,2002 Oliver Baltzer <ob@racon.net>

if test -z "`echo $0 |grep \"^\/\"`" ; then
    BASE=`echo "\`pwd\`/$0" | sed -e "s/\/[^\/]*$/\/../g"`
else
    BASE=`echo $0 | sed -e "s/\/[^\/]*$/\/../g"`
fi

. $BASE/etc/bridge-fw.conf

if test -z "$ROUTER_MAC" ; then
    ROUTER_MAC="00:00:00:00:00:00"
fi

if test -z "$1" -o -z "$2" -o -z "$3" ;  then
    echo "Missing argument.";
    exit 1;
else
    iptables -D FORWARD -s $2 -m mac --mac-source $1 \
             --mac-destination $ROUTER_MAC -j $3 > /dev/null 2>&1;
    test $? -ne 0 && exit 1;
    iptables -D FORWARD -d $2 -m mac --mac-destination $1 \
             --mac-source $ROUTER_MAC -j $3  > /dev/null 2>&1;
    test $? -ne 0 && exit 1;
fi
exit 0;
