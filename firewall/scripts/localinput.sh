#!/bin/sh
#
# $Id: localinput.sh,v 1.1 2002/01/06 21:39:16 racon Exp $
#
# enables access for services the firewall itself provides or uses.
#
# Copyright (C) 2001,2002 Oliver Baltzer <ob@racon.net>

if test -z "`echo $0 |grep \"^\/\"`" ; then
    BASE=`echo "\`pwd\`/$0" | sed -e "s/\/[^\/]*$/\/..\/../g"`
else
    BASE=`echo $0 | sed -e "s/\/[^\/]*$/\/..\/../g"`
fi

. $BASE/etc/bridge-fw.conf

NAME=`echo $0 | sed -e "s/.*\/\([^\/]*\)$/\1/g"`

echo -n "$NAME: SSH access to the firewall from local network..."
iptables -A INPUT -s $LOCAL_NETWORK -p tcp --dport 22 --sport 1024: \
         -j ACCEPT > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi

echo -n "$NAME: Allow DNS query reply from any external nameserver..."
iptables -A INPUT -s 0.0.0.0/0 -p udp --sport 53 --dport 1024: \
         -j ACCEPT > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi

echo -n "$NAME: Allow HTTP queries to the firewall..."
iptables -A INPUT -s 0.0.0.0/0 -p tcp --sport 1024: --dport 80 \
         -j ACCEPT > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi

echo -n "$NAME: Allow HTTPS queries to the firewall..."
iptables -A INPUT -s 0.0.0.0/0 -p tcp --sport 1024: --dport 443 \
         -j ACCEPT > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi

echo -n "$NAME: Allow NetBios replies to firewall for notebook " \
        "registration..."
iptables -A INPUT -s 141.45.0.0/16 -p tcp --sport 139 --dport 1024: \
         -j ACCEPT > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi

echo -n "$NAME: Allow ICMP replies to firewall..."
iptables -A INPUT -p icmp \
         -j ACCEPT > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi

echo -n "$NAME: Allow the firewall to be a SSH client..."
iptables -A INPUT -p tcp -s 0.0.0.0/0 --sport 22 --dport 1024: \
         -j ACCEPT > /dev/null 2>&1
if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi

iptables -P INPUT ACCEPT

exit 0

