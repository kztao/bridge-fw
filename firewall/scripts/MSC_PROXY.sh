#!/bin/sh
#
# $Id: DEFAULT_CLIENT.sh,v 1.1 2002/01/06 21:39:16 racon Exp $
#
# adds a chain needed by windows clients.
#
# Copyright (C) 2001,2002 Oliver Baltzer <ob@racon.net>

if test -z "`echo $0 |grep \"^\/\"`" ; then
    BASE=`echo "\`pwd\`/$0" | sed -e "s/\/[^\/]*$/\/..\/../g"`
else
    BASE=`echo $0 | sed -e "s/\/[^\/]*$/\/..\/../g"`
fi

. $BASE/etc/bridge-fw.conf

NAME=`echo $0 | sed -e "s/.*\/\([^\/]*\)$/\1/g"`

CHAIN_NAME=MSC_PROXY

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

echo -n "$NAME: Allow access to port 81 from rdg.ac.uk network..."
iptables -A $CHAIN_NAME -s 134.225.0.0/16 -d 0/0 -p tcp \
         --dport 81 --sport 1024: \
         -j ACCEPT > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; \
else echo "failed" ; exit 1 ; fi

echo -n "$NAME: Allow replies from port 81 to rdg.ac.uk network..."
iptables -A $CHAIN_NAME -d 134.225.0.0/16 -s 0/0 -p tcp \
         --sport 81 --dport 1024: \
         -j ACCEPT > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; \
else echo "failed" ; exit 1 ; fi

exit 0

