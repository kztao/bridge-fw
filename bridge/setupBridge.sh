#!/bin/sh
#
# $Id: setupBridge.sh,v 1.2 2002/01/07 20:29:03 racon Exp $
#
# This script is used to setup the bridging mode for the interfaces
# specified in the $BASE/etc/bridge-fw.conf file. It will also configures
# the bridge interface as a network interface if BR_IFCONFIG is not empty.
#
# It is used like a System V init script, 'start' as the first argument
# will setup the system and 'stop' as the first argument will shutdown the
# bridge.
#
# Copyright (C) 2001,2002 Oliver Baltzer <ob@racon.net>

if test -z "`echo $0 |grep \"^\/\"`" ; then
    BASE=`echo "\`pwd\`/$0" | sed -e "s/\/[^\/]*$/\/../g"`
else
    BASE=`echo $0 | sed -e "s/\/[^\/]*$/\/../g"`
fi

. $BASE/etc/bridge-fw.conf

if test -z "$BRIDGE_INTERFACES" ; then
    echo "No interfaces for the bridge specified, please edit file"
    echo "$BASE/etc/bridge-fw.conf. "
    echo "Exiting..."
    exit 1
else
    case "$1" in
        start)
            echo -n "Creating bridge interface..."
            brctl addbr br0 > /dev/null 2>&1
            if test $? -eq 0 ; then echo "ok" ; \
                else echo "failed" ; exit 1 ; fi
            if test "$ENABLE_STP" = "yes" -o "$ENABLE_STP" = "YES" ; then
                echo -n "Enable spanning tree protocol" \
                        "(STP) for bridge..."
                brctl stp br0 on > /dev/null 2>&1
                if test $? -eq 0 ; then echo "ok" ; \
                    else echo "failed" ; exit 1 ; fi
            else
                echo -n "Disable spanning tree protocol" \
                        "(STP) for bridge..."
                brctl stp br0 off > /dev/null 2>&1
                if test $? -eq 0 ; then echo "ok" ; \
                    else echo "failed" ; exit 1 ; fi
            fi
            for D in $BRIDGE_INTERFACES ; do
                echo -n "Setting interface $D into promiscuous mode..."
                ifconfig $D promisc up > /dev/null 2>&1
                if test $? -eq 0 ; then echo "ok" ; \
                    else echo "failed" ; exit 1 ; fi
                echo -n "Adding interface $D to bridge..."
                brctl addif br0 $D > /dev/null 2>&1
                if test $? -eq 0 ; then echo "ok" ; \
                    else echo "failed" ; exit 1 ; fi
            done
            if test -n "$BR_IFCONFIG" ; then
                echo -n "Configuring bridge interface" \
                        "for network access..."
                ifconfig br0 $BR_IFCONFIG > /dev/null 2>&1
                if test $? -eq 0 ; then echo "ok" ; \
                    else echo "failed" ; exit 1 ; fi
                if test -n "$BR_GATEWAY" ; then
                    echo -n "Setting default gateway for bridge" \
                            "interface to $BR_GATEWAY..."
                    route add default gw $BR_GATEWAY br0 > /dev/null 2>&1
                    if test $? -eq 0 ; then echo "ok" ; \
                        else echo "failed" ; exit 1 ; fi
                fi
            fi
            ;;
        stop)
            echo -n "Shutting down bridge interface br0..."
            ifconfig br0 down 
            if test $? -eq 0 ; then echo "ok" ; \
                else echo "failed" ; exit 1 ; fi
            echo -n "Disable bridge interface br0..."
            brctl delbr br0
            if test $? -eq 0 ; then echo "ok" ; \
                else echo "failed" ; exit 1 ; fi
            ;;
        restart)
            $0 stop || $0 start
            exit $?
            ;;
        *)
            echo "Usage: setupBridge.sh {start|stop|restart}"
            exit 1;
            ;;
    esac
fi

exit 0
