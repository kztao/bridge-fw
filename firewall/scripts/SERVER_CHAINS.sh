#!/bin/sh
#
# $Id: DEFAULT_CLIENT_SERVICES.sh,v 1.1 2002/01/06 21:39:16 racon Exp $
#
# reads the file $BASE/etc/server_services.conf and creates chains
# for all services defined there. Servers providing one or more of these
# services should reference to these automatically created chains.
#
# Copyright (C) 2001,2002 Oliver Baltzer <ob@racon.net>

if test -z "`echo $0 |grep \"^\/\"`" ; then
    BASE=`echo "\`pwd\`/$0" | sed -e "s/\/[^\/]*$/\/..\/../g"`
else
    BASE=`echo $0 | sed -e "s/\/[^\/]*$/\/..\/../g"`
fi

. $BASE/etc/bridge-fw.conf

NAME=`echo $0 | sed -e "s/.*\/\([^\/]*\)$/\1/g"`

if test -f $BASE/$SERVER_SERVICES -a -r $BASE/$SERVER_SERVICES ; then

    for SERVICE in `cat $BASE/$SERVER_SERVICES | grep "^\w" | awk '{print $1}'` ; do

        CHAIN_NAME=SERVER_`echo $SERVICE | \
            perl -e "while(<STDIN>) { y/[a-z]/[A-Z]/; print $_ ; }"`
    
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
        sh -c "`cat $BASE/$SERVER_SERVICES | grep "^$SERVICE" | sed -e "s/\// /g" \
                | awk '{ if ($3 ~ "^(udp|tcp)$" && $2 ~ "^[0-9]+$") { \
                    print "echo \\"'$NAME': Adding service", \
                          $1, "("$2"/"$3")...\\""; \
                    print "iptables -A '$CHAIN_NAME' " \
                          "-d '$LOCAL_NETWORK' " \
                          "-s '$EXTERNAL_NETWORK' -p "$3 \
                          " --dport "$2" " \
                          "--sport 1024: -j ACCEPT"; \
                
                    print "iptables -A '$CHAIN_NAME' " \
                          "-d '$EXTERNAL_NETWORK' " \
                          "-s '$LOCAL_NETWORK' -p "$3 \
                          " --sport "$2" " \
                          "--dport 1024: -j ACCEPT"; \
                    } else { \
                    print "echo \\"'$NAME': In service "$1 \
                          " invalid value ("$2"/"$3") specified.\\""; \
                    } \
                }'`"
        echo "$NAME: done."
    
    done
else
    echo "$NAME: Unable to read file $BASE/$SERVER_SERVICES!"
    exit 1
fi

exit 0
