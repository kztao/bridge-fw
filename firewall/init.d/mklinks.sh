#!/bin/sh
#
# $Id: mklinks.sh,v 1.1 2002/01/06 21:39:14 racon Exp $
#
# creates the symbolic links to the scripts which initilizes the firewall
# in the default installation.
#
# Copyright (C) 2001,2002 Oliver Baltzer <ob@racon.net>

if test -z "`echo $0 |grep \"^\/\"`" ; then
    BASE=`echo "\`pwd\`/$0" | sed -e "s/\/[^\/]*$/\/..\/../g"`
else
    BASE=`echo $0 | sed -e "s/\/[^\/]*$/\/..\/../g"`
fi

ln -s $BASE/firewall/scripts/flushall.sh \
      $BASE/firewall/init.d/script00-flushall.sh

ln -s $BASE/firewall/scripts/policy.sh \
      $BASE/firewall/init.d/script01-policy.sh

ln -s $BASE/firewall/scripts/localinput.sh \
      $BASE/firewall/init.d/script02-localinput.sh
      
ln -s $BASE/firewall/scripts/defaultforward.sh \
      $BASE/firewall/init.d/script03-defaultforward.sh
      
ln -s $BASE/firewall/scripts/ICMP.sh \
      $BASE/firewall/init.d/script04-ICMP.sh

ln -s $BASE/firewall/scripts/DEFAULT_CLIENT_SERVICES.sh \
      $BASE/firewall/init.d/script05-DEFAULT_CLIENT_SERVICES.sh
      
ln -s $BASE/firewall/scripts/WINDOWS_CLIENT.sh \
      $BASE/firewall/init.d/script05-WINDOWS_CLIENT.sh

ln -s $BASE/firewall/scripts/LINUX_CLIENT.sh \
      $BASE/firewall/init.d/script05-LINUX_CLIENT.sh

ln -s $BASE/firewall/scripts/DEFAULT_CLIENT.sh \
      $BASE/firewall/init.d/script10-DEFAULT_CLIENT.sh

ln -s $BASE/firewall/scripts/SERVER_CHAINS.sh \
      $BASE/firewall/init.d/script10-SERVER_CHAINS.sh

ln -s $BASE/firewall/scripts/WINDOWS_SERVER.sh \
      $BASE/firewall/init.d/script10-WINDOWS_SERVER.sh

ln -s $BASE/firewall/scripts/DIRECT_CONNECT_CLIENT.sh \
      $BASE/firewall/init.d/script10-DIRECT_CONNECT_CLIENT.sh

ln -s $BASE/firewall/scripts/IPV6_TUNNEL.sh \
      $BASE/firewall/init.d/script10-IPV6_TUNNEL.sh

ln -s $BASE/firewall/scripts/MSC_PROXY.sh \
      $BASE/firewall/init.d/script10-MSC_PROXY.sh
