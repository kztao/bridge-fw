#!/bin/sh
#
# $Id: ICMP.sh,v 1.1 2002/01/06 21:39:16 racon Exp $
#
# This iptables chain allows a host to send ICMP packages to other hosts in
# any other network.
#
# Copyright (C) 2001,2002 Oliver Baltzer <ob@racon.net>

if test -z "`echo $0 |grep \"^\/\"`" ; then
    BASE=`echo "\`pwd\`/$0" | sed -e "s/\/[^\/]*$/\/..\/../g"`
else
    BASE=`echo $0 | sed -e "s/\/[^\/]*$/\/..\/../g"`
fi

. $BASE/etc/bridge-fw.conf

NAME=`echo $0 | sed -e "s/.*\/\([^\/]*\)$/\1/g"`

CHAIN_NAME=ICMP

# check if chain already exists
iptables -L $CHAIN_NAME -n > /dev/null 2>&1
if test $? -ne 0 ; then
    echo -n "$NAME: Creating $CHAIN_NAME chain..."
    iptables -N $CHAIN_NAME > /dev/null 2>&1
    if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi
else
    echo -n "$NAME: Flushing $CHAIN_NAME chain..."
    iptables -F $CHAIN_NAME > /dev/null 2>&1
    if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi
fi

echo -n "$NAME: Allow ICMP from local network to external networks..."
iptables -A $CHAIN_NAME -s $LOCAL_NETWORK -d $EXTERNAL_NETWORK \
         -p icmp -j ACCEPT > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi

echo -n "$NAME: Allow ICMP from external networks to local network..."
iptables -A $CHAIN_NAME -s $EXTERNAL_NETWORK -d $LOCAL_NETWORK \
         -p icmp -j ACCEPT > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi

exit 0
