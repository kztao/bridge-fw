#!/bin/sh
#
# $Id: flushall.sh,v 1.1 2002/01/06 21:39:16 racon Exp $
#
# sets the firewall to a defined state and deletes all non-standard chains.
#
# Copyright (C) 2001,2002 <ob@racon.net>

if test -z "`echo $0 |grep \"^\/\"`" ; then
    BASE=`echo "\`pwd\`/$0" | sed -e "s/\/[^\/]*$/\/..\/../g"`
else
    BASE=`echo $0 | sed -e "s/\/[^\/]*$/\/..\/../g"`
fi

. $BASE/etc/bridge-fw.conf

NAME=`echo $0 | sed -e "s/.*\/\([^\/]*\)$/\1/g"`

# getting all chains and flush them
for C in `iptables -L | grep "^Chain \w*" |awk '{print $2}'` ; do
    
    echo -n "$NAME: Flushing chain $C..."
    iptables -F $C > /dev/null 2>&1
    if test $? -eq 0 ; then echo "ok" ; else echo "failed" ; exit 1 ; fi
    
    # delete the chain if it not a standard chain 
    if test "$C" != "INPUT" -a "$C" != "FORWARD" -a "$C" != "OUTPUT" ; then
        echo -n "$NAME: Deleting chain $C..."
        iptables -X $C > /dev/null 2>&1
        if test $? -eq 0 ; then echo "ok" ; \
            else echo "failed" ; exit 1 ; fi
    fi
done

exit 0
