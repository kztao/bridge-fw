#!/bin/sh
#
# $Id: DEFAULT_CLIENT_SERVICES.sh,v 1.1 2002/01/06 21:39:16 racon Exp $
#
# Creates an iptables chain containing rules allowing a client in the
# client network to access several services in an external network which
# are defined by a /etc/services layouted file. Uncommented entries are
# valid ports all other ports will not be enabled. This chain should be
# used in an environment where the default policy is DROP.
#
# Copyright (C) 2001,2002 Oliver Baltzer <ob@racon.net>

if test -z "`echo $0 |grep \"^\/\"`" ; then
    BASE=`echo "\`pwd\`/$0" | sed -e "s/\/[^\/]*$/\/..\/../g"`
else
    BASE=`echo $0 | sed -e "s/\/[^\/]*$/\/..\/../g"`
fi

. $BASE/etc/bridge-fw.conf

NAME=`echo $0 | sed -e "s/.*\/\([^\/]*\)$/\1/g"`

CHAIN_NAME=DEFAULT_CLIENT_SERVICES

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

echo "$NAME: Inserting rules in $CHAIN_NAME chain..."
if test -f $BASE/$CLIENT_SERVICES -a -r $BASE/$CLIENT_SERVICES ; then
    sh -c "`cat $BASE/$CLIENT_SERVICES | grep "^\w" | sed -e "s/\// /g" \
        | awk '{ if ($3 ~ "^(udp|tcp)$" && $2 ~ "^[0-9]+$") { \
                    print "echo \\"'$NAME': Adding service", \
                          $1, "("$2"/"$3")...\\""; \
                    print "iptables -A '$CHAIN_NAME' " \
                          "-s '$LOCAL_NETWORK' " \
                          "-d '$EXTERNAL_NETWORK' -p "$3 \
                          " --sport 1024: " \
                          "--dport "$2" -j ACCEPT"; \
                
                    print "iptables -A '$CHAIN_NAME' " \
                          "-s '$EXTERNAL_NETWORK' " \
                          "-d '$LOCAL_NETWORK' -p "$3 \
                          " --sport "$2" " \
                          "--dport 1024: -j ACCEPT"; \
                 } else { \
                    print "echo \\"'$NAME': In service "$1 \
                          " invalid value ("$2"/"$3") specified.\\""; \
                 } \
               }'`"
    echo "$NAME: done."
else
    echo "$NAME: Unable to read file $BASE/$CLIENT_SERVICES!"
    exit 1
fi

exit 0
