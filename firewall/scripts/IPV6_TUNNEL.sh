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

CHAIN_NAME=IPV6_TUNNEL

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
        
        echo -n "$NAME: Allow IPv6 to trusted network $I..."
        iptables -A $CHAIN_NAME -s $LOCAL_NETWORK -d $I -p ipv6 \
                 -j ACCEPT > /dev/null 2>&1
        if test $? -eq 0 ; then echo "ok" ; \
        else echo "failed" ; exit 1 ; fi
        
        echo -n "$NAME: Allow IPv6 from trusted network $I..."
        iptables -A $CHAIN_NAME -s $I -d $LOCAL_NETWORK -p ipv6 \
                 -j ACCEPT > /dev/null 2>&1
        if test $? -eq 0 ; then echo "ok" ; \
        else echo "failed" ; exit 1 ; fi
        
        echo -n "$NAME: Allow IPv6-route to trusted network $I..."
        iptables -A $CHAIN_NAME -s $LOCAL_NETWORK -d $I -p ipv6-route \
                 -j ACCEPT > /dev/null 2>&1
        if test $? -eq 0 ; then echo "ok" ; \
        else echo "failed" ; exit 1 ; fi
        
        echo -n "$NAME: Allow IPv6-route from trusted network $I..."
        iptables -A $CHAIN_NAME -s $I -d $LOCAL_NETWORK -p ipv6-route \
                 -j ACCEPT > /dev/null 2>&1
        if test $? -eq 0 ; then echo "ok" ; \
        else echo "failed" ; exit 1 ; fi
        
        echo -n "$NAME: Allow IPv6-frag to trusted network $I..."
        iptables -A $CHAIN_NAME -s $LOCAL_NETWORK -d $I -p ipv6-frag \
                 -j ACCEPT > /dev/null 2>&1
        if test $? -eq 0 ; then echo "ok" ; \
        else echo "failed" ; exit 1 ; fi
        
        echo -n "$NAME: Allow IPv6-frag from trusted network $I..."
        iptables -A $CHAIN_NAME -s $I -d $LOCAL_NETWORK -p ipv6-frag \
                 -j ACCEPT > /dev/null 2>&1
        if test $? -eq 0 ; then echo "ok" ; \
        else echo "failed" ; exit 1 ; fi
        
        echo -n "$NAME: Allow IPv6-icmp to trusted network $I..."
        iptables -A $CHAIN_NAME -s $LOCAL_NETWORK -d $I -p ipv6-icmp \
                 -j ACCEPT > /dev/null 2>&1
        if test $? -eq 0 ; then echo "ok" ; \
        else echo "failed" ; exit 1 ; fi
        
        echo -n "$NAME: Allow IPv6-icmp from trusted network $I..."
        iptables -A $CHAIN_NAME -s $I -d $LOCAL_NETWORK -p ipv6-icmp \
                 -j ACCEPT > /dev/null 2>&1
        if test $? -eq 0 ; then echo "ok" ; \
        else echo "failed" ; exit 1 ; fi
        
        echo -n "$NAME: Allow IPv6-nonxt to trusted network $I..."
        iptables -A $CHAIN_NAME -s $LOCAL_NETWORK -d $I -p ipv6-nonxt \
                 -j ACCEPT > /dev/null 2>&1
        if test $? -eq 0 ; then echo "ok" ; \
        else echo "failed" ; exit 1 ; fi
        
        echo -n "$NAME: Allow IPv6-nonxt from trusted network $I..."
        iptables -A $CHAIN_NAME -s $I -d $LOCAL_NETWORK -p ipv6-nonxt \
                 -j ACCEPT > /dev/null 2>&1
        if test $? -eq 0 ; then echo "ok" ; \
        else echo "failed" ; exit 1 ; fi
        
        echo -n "$NAME: Allow IPv6-opts to trusted network $I..."
        iptables -A $CHAIN_NAME -s $LOCAL_NETWORK -d $I -p ipv6-opts \
                 -j ACCEPT > /dev/null 2>&1
        if test $? -eq 0 ; then echo "ok" ; \
        else echo "failed" ; exit 1 ; fi
        
        echo -n "$NAME: Allow IPv6-opts from trusted network $I..."
        iptables -A $CHAIN_NAME -s $I -d $LOCAL_NETWORK -p ipv6-opts \
                 -j ACCEPT > /dev/null 2>&1
        if test $? -eq 0 ; then echo "ok" ; \
        else echo "failed" ; exit 1 ; fi
done

exit 0

