#!/usr/bin/perl -w
#
# $Id: fwregd.pl,v 1.2 2002/01/07 20:30:00 racon Exp $
#
# the firewall registration daemon. It observes the dhcpd.leases file
# and sets the status for hosts entering the network using DHCP or leaving
# after their lease time has expired. It also enables and disables these
# hosts in the firewall configuration.
#
# Copyright (C) 2001,2002 Oliver Baltzer <ob@racon.net>

use FindBin;
use lib $FindBin::Bin;
use Help::Tools qw(:Strings :Logging :IPv4 :Files);
use DHCP::Parser qw(:Parser);
use HostDB::DB;
use HostDB::Host;
use Socket;
use POSIX;

$VERSION = "1.0-alpha1";

# starting daemon
    
# reading the configuration file
$conf = parse_config_file("$FindBin::Bin/../etc/bridge-fw.conf");

# setting the logging level
$conf->{LOGFILE} = "$FindBin::Bin/../" . $conf->{LOGFILE} 
    if $conf->{LOGFILE} !~ m/^\//;

if(defined $conf->{LOGLEVEL})
{
    if(init_log($LT_FILE, $conf->{LOGLEVEL}, $conf->{LOGFILE}) == -1)
    {
        print STDERR "Cannot open logging system!\n";
        exit(-1);
    }
}
else
{
    if(init_log($LT_FILE, 2, $conf->{LOGFILE}) == -1)
    {
        print STDERR "Cannot open logging system!\n";
        exit(-1);
    }
}


# set all neccessary variables
$HostDB::Host::onlineScript = "$FindBin::Bin/../" 
                            . $conf->{ENABLE_TARGET_SCRIPT};
$HostDB::Host::offlineScript = "$FindBin::Bin/../" 
                             . $conf->{DISABLE_TARGET_SCRIPT};
$HostDB::Host::defaultTarget = $conf->{DEFAULT_TARGET};

# tell the DHCP config file parser to ignore errors
DHCP::Parser::ignore_errors(1);

# create the hostdb system
$hostdb = HostDB::DB->new($conf->{DHCP_CONFIG}, $conf->{DHCP_LEASES}, 
                          "$FindBin::Bin/../" . $conf->{TARGETS_MAP});
if(defined $hostdb)
{
    # start the hostdb system
    if(fork() == 0)
    {
        if(!POSIX::setsid())
        {
            print STDERR "Cannot start new session!\n";
            exit(-1);
        }
        
        logline($L_INFO, "Firewall Registration Daemon v$VERSION"
                         . " has been started.");
                         
        $SIG{INT} = $SIG{TERM} = $SIG{HUP} = 
            $SIG{USR1} = $SIG{USR2} = sub { return; };
        
        $hostdb->start();
        logline($L_INFO, "Cleaning up...");
        $hostdb->cleanup();
        logline($L_INFO, "Exiting...");
        exit(0);
    }
}
else
{
    logline($L_ERROR, "Cannot create host database. Exiting...");
    close_log();
    exit(-1);
}

close_log();
exit(0);
