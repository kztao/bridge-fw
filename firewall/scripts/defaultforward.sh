#!/bin/sh
#
# $Id: defaultforward.sh,v 1.1 2002/01/06 21:39:16 racon Exp $
# 
# initializes the firewall system, that all already established or related
# connection can pass the firewall and all invalid packages will be logged
# and dropped.
#
# Copyright (C) 2001,2002 Oliver Baltzer <ob@racon.net>

if test -z "`echo $0 |grep \"^\/\"`" ; then
    BASE=`echo "\`pwd\`/$0" | sed -e "s/\/[^\/]*$/\/..\/../g"`
else
    BASE=`echo $0 | sed -e "s/\/[^\/]*$/\/..\/../g"`
fi

. $BASE/etc/bridge-fw.conf

NAME=`echo $0 | sed -e "s/.*\/\([^\/]*\)$/\1/g"`

echo -n "$NAME: Loading FTP connection tracking module..."
modprobe ip_conntrack_ftp > /dev/null 2>&1
test $? -eq 0 && echo "ok" || echo "failed, no FTP connection tracking"

echo -n "$NAME: Accept all established or related TCP connections..."
iptables -A FORWARD -p tcp -m state --state ESTABLISHED,RELATED \
         -j ACCEPT > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi

echo -n "$NAME: Accept all established or related UDP connections..."
iptables -A FORWARD -p udp -m state --state ESTABLISHED,RELATED \
         -j ACCEPT > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi

echo -n "$NAME: Log all invalid packages..."
iptables -A FORWARD -s 0.0.0.0/0 -d 0.0.0.0/0 \
         -m state --state INVALID -j LOG > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi

echo -n "$NAME: Drop all invalid packages..."
iptables -A FORWARD -s 0.0.0.0/0 -d 0.0.0.0/0 \
         -m state --state INVALID -j DROP > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi

exit 0
