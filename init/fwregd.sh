#!/bin/sh
#
# $Id: fwregd.sh,v 1.1 2002/01/07 20:31:52 racon Exp $
#
# a System V init script for starting and shutting down the Firewall
# Registration Daemon.
#
# Copyright (C) 2001,2002 Oliver Baltzer <ob@racon.net>

INST_DIR=/opt/bridge-fw

case "$1" in
    start)
        echo "Starting Firewall Registration Daemon..."
        $INST_DIR/dhcp/fwregd.pl
        ;;
    stop)
        echo "Shutting down Firewall Registration Daemon..."
        PID=`ps xa | grep "[f]wregd.pl"| awk '{print $1}'`
        if test -z "$PID" ; then
            echo "Firewall Registration Daemon is not running."
        else
            for P in "$PID" ; do
                kill -TERM $P
            done
        fi
        ;;
    restart)
        $0 stop || $0 start
        exit $?
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac

exit 0
