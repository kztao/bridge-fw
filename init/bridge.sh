#!/bin/sh
#
# $Id: bridge.sh,v 1.1 2002/01/07 20:31:52 racon Exp $
#
# System V init script to start the bridge setup program.
#
# Copyright (C) 2001,2002 Oliver Baltzer <ob@racon.net>

INST_DIR=/opt/bridge-fw

case "$1" in
    start)
        echo "Setup the bridge system..."
        $INST_DIR/bridge/setupBridge.sh start
        ;;
    stop)
        echo "Shutdown the bridge system..."
        $INST_DIR/bridge/setupBridge.sh stop
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
        
    

