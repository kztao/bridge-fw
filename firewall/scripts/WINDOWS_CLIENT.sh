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

CHAIN_NAME=WINDOWS_CLIENT

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

for I in $TRUSTED_SERVERS ; do
        
        echo -n "$NAME: Allow access from client to" \
                "TCP port 139 in trusted network $I..."
        iptables -A $CHAIN_NAME -s $LOCAL_NETWORK -d $I -p tcp \
                 --sport 1024: --dport 139 -j ACCEPT > /dev/null 2>&1
        if test $? -eq 0 ; then echo "ok" ; \
        else echo "failed" ; exit 1 ; fi
        
        echo -n "$NAME: Allow response from trusted network $I" \
                "from TCP port 139 to client..." 
        iptables -A $CHAIN_NAME -s $I -d $LOCAL_NETWORK -p tcp \
                 --sport 139 --dport 1024: -j ACCEPT > /dev/null 2>&1
        if test $? -eq 0 ; then echo "ok" ; \
        else echo "failed" ; exit 1 ; fi
        
        echo -n "$NAME: Allow access from client from UDP port 137 to" \
                "UDP port 137 in trusted network $I..."
        iptables -A $CHAIN_NAME -s $LOCAL_NETWORK -d $I -p udp \
                 --sport 137 --dport 137 -j ACCEPT > /dev/null 2>&1
        if test $? -eq 0 ; then echo "ok" ; \
        else echo "failed" ; exit 1 ; fi
        
        echo -n "$NAME: Allow access from trusted network $I" \
                "from UDP port 137 to client" \
                "UDP port 137..."
        iptables -A $CHAIN_NAME -s $I -d $LOCAL_NETWORK -p udp \
                 --sport 137 --dport 137 -j ACCEPT > /dev/null 2>&1
        if test $? -eq 0 ; then echo "ok" ; \
        else echo "failed" ; exit 1 ; fi
        
        echo -n "$NAME: Allow access from client from UDP port 138 to" \
                "UDP port 138 in trusted network $I..."
        iptables -A $CHAIN_NAME -s $LOCAL_NETWORK -d $I -p udp \
                 --sport 138 --dport 138 -j ACCEPT > /dev/null 2>&1
        if test $? -eq 0 ; then echo "ok" ; \
        else echo "failed" ; exit 1 ; fi
        
        echo -n "$NAME: Allow access from trusted network $I" \
                "from UDP port 138 to client" \
                "UDP port 138..."
        iptables -A $CHAIN_NAME -s $I -d $LOCAL_NETWORK -p udp \
                 --sport 138 --dport 138 -j ACCEPT > /dev/null 2>&1
        if test $? -eq 0 ; then echo "ok" ; \
        else echo "failed" ; exit 1 ; fi
done

exit 0

