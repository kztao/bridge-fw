#!/bin/sh
#
# $Id: policy.sh,v 1.1 2002/01/06 21:39:16 racon Exp $
#
# setting the default policies the firewall is using.
#
# Copyright (C) 2001,2002 Oliver Baltzer <ob@racon.net>

if test -z "`echo $0 |grep \"^\/\"`" ; then
    BASE=`echo "\`pwd\`/$0" | sed -e "s/\/[^\/]*$/\/..\/../g"`
else
    BASE=`echo $0 | sed -e "s/\/[^\/]*$/\/..\/../g"`
fi

. $BASE/etc/bridge-fw.conf

NAME=`echo $0 | sed -e "s/.*\/\([^\/]*\)$/\1/g"`

echo -n "$NAME: Setting default policy for chain INPUT to DROP..."
iptables -P INPUT DROP > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi
echo -n "$NAME: Setting default policy for chain FORWARD to DROP..."
iptables -P FORWARD DROP > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi

exit 0
