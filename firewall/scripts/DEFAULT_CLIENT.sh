#!/bin/sh
#
# $Id: DEFAULT_CLIENT.sh,v 1.1 2002/01/06 21:39:16 racon Exp $
#
# combines the ICMP and the DEFAULT_CLIENT_SERVICES targets to one.
#
# Copyright (C) 2001,2002 Oliver Baltzer <ob@racon.net>

if test -z "`echo $0 |grep \"^\/\"`" ; then
    BASE=`echo "\`pwd\`/$0" | sed -e "s/\/[^\/]*$/\/..\/../g"`
else
    BASE=`echo $0 | sed -e "s/\/[^\/]*$/\/..\/../g"`
fi

. $BASE/etc/bridge-fw.conf

NAME=`echo $0 | sed -e "s/.*\/\([^\/]*\)$/\1/g"`

CHAIN_NAME=DEFAULT_CLIENT

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

echo -n "$NAME: Allow ICMP for a default client using ICMP chain..."
iptables -A $CHAIN_NAME -j ICMP > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi

echo -n "$NAME: Redirect all to DEFAULT_CLIENT_SERVICES chain..."
iptables -A $CHAIN_NAME -j DEFAULT_CLIENT_SERVICES > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi

echo -n "$NAME: Enable Windows Client Services..."
iptables -A $CHAIN_NAME -j WINDOWS_CLIENT > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi

echo -n "$NAME: Enable Linux Client Services..."
iptables -A $CHAIN_NAME -j LINUX_CLIENT > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi

exit 0

