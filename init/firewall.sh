#!/bin/sh
#
# $Id: firewall.sh,v 1.1 2002/01/07 20:31:52 racon Exp $
#
# a System V init script to setup the firewall.
#
# Copyright (C) 2001,2002 Oliver Baltzer <ob@racon.net>

INST_DIR=/opt/Projects/bridge-fw

case "$1" in
    start)
        echo "Starting Firewall..."
        $INST_DIR/firewall/initFirewall.sh
        ;;
    stop)
        echo "Stopping Firewall..."
        echo "I don't really do anything here, it needs some changes."
        # XXX enable shutting down of firewall
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
