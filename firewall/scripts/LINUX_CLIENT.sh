#!/bin/sh
#
# $Id: DEFAULT_CLIENT.sh,v 1.1 2002/01/06 21:39:16 racon Exp $
#
# adds a chain for NFS and NIS access
#
# Copyright (C) 2001,2002 Oliver Baltzer <ob@racon.net>

if test -z "`echo $0 |grep \"^\/\"`" ; then
    BASE=`echo "\`pwd\`/$0" | sed -e "s/\/[^\/]*$/\/..\/../g"`
else
    BASE=`echo $0 | sed -e "s/\/[^\/]*$/\/..\/../g"`
fi

. $BASE/etc/bridge-fw.conf

NAME=`echo $0 | sed -e "s/.*\/\([^\/]*\)$/\1/g"`

CHAIN_NAME=LINUX_CLIENT

iptables -L $CHAIN_NAME -n > /dev/null 2>&1
if test $? != 0 ; then
    echo -n "$NAME: Creating $CHAIN_NAME chain..."
    iptables -N $CHAIN_NAME > /dev/null 2>&1
    if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi
else
    echo -n "$NAME: Flushing $CHAIN_NAME chain..."
    iptables -F $CHAIN_NAME > /dev/null 2>&1
    if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi
fi

        
echo -n "$NAME: Allow access from client to all TCP" \
        "ports in local network..."
iptables -A $CHAIN_NAME -s $LOCAL_NETWORK -d $LOCAL_NETWORK \
         -p tcp \
         -j ACCEPT > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; \
else echo "failed" ; exit 1 ; fi

echo -n "$NAME: Allow access from client to all UDP" \
        "ports in local network..."
iptables -A $CHAIN_NAME -s $LOCAL_NETWORK -d $LOCAL_NETWORK \
         -p udp \
         -j ACCEPT > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; \
else echo "failed" ; exit 1 ; fi
        
exit 0

