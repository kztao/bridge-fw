# $Id: DB.pm,v 1.3 2002/01/07 20:30:34 racon Exp $

package HostDB::DB;

use strict;
use vars qw(@EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION @ISA $interval
            $tolerance);
use Help::Tools qw(:Logging :Strings :Arrays :Files);
use DHCP::Parser qw(:Parser);
use HostDB::Host;
use HostDB::Observer;

use Exporter;
@ISA = qw(Exporter);

@EXPORT = qw();
@EXPORT_OK = qw();
%EXPORT_TAGS = ();

$VERSION = 0.01;

# the interval in which the time check should be performed
$interval = 20;

# the tolerance used in lease end time (will be added to lease end time)
# for clients which do not reactivate their leases in time
$tolerance = 30;

sub new
{
    my $self = {};
    bless($self, shift);

    if(!defined $_[0] || !defined $_[1])
    {
        logline($L_ERROR, "HostDB::DB: Invalid number of aguments.");
        return undef;
    }
    else
    {
        # the filename of the configuration file for the DHCP server
        my $conf_file = $_[0];
        # the filename of the leases file of the DHCP server
        my $leases_file = $_[1];
        # the file where the targets for the hosts are defined
        my $targets_file = $_[2];
        
        # check these files
        if(!-f $conf_file || !-r $conf_file)
        {
            logline($L_ERROR, "HostDB::DB: Cannot read DHCP "
                              . "configuration file '$conf_file'.");
            return undef;
        }
        if(!-f $leases_file || !-r $leases_file)
        {
            logline($L_ERROR, "HostDB::DB: Cannot read DHCP "
                              . " leases file '$leases_file'.");
            return undef;
        }
        if(!-f $targets_file || !-r $targets_file)
        {
            logline($L_ERROR, "HostDB::DB: Cannot read targets "
                              . " file '$targets_file'.");
            return undef;
        }

        # initialize the local data
        $self->{conf_file} = $conf_file;
        $self->{leases_file} = $leases_file;
        # create an empty database 
        $self->{db} = {};
        $self->{targets_file} = $targets_file; 
        
        # update the database the first time
        if($self->updateDB() == -1)
        {
            logline($L_ERROR, "HostDB::DB: Cannot update database.");
            return undef;
        }
    }
    return $self;
}

sub start
{
    my $self = shift;
    my $ecode;
        
    # setting signal handler for database reload
    $SIG{HUP} = sub { $self->updateDB(); };
    $SIG{USR1} = sub { logline($L_DEBUG, $self->getDBasString()) }; 
    
    # setting the time checker
    $SIG{ALRM} = sub { $self->runTimeCheck(); };
    alarm($interval);
    
    # starting the observer
    if(($ecode = $self->startObserver()) != 0)
    {
        logline($L_ERROR, "Cannot start observer task. Error: $ecode");
        return -1;
    }
    
    return 1;
}

sub startObserver
{
    my $self = shift;
    
    # create a new Observer object
    my $observer = HostDB::Observer->new($self);
    # if the observer object cannot be created it reaturn undef
    if(!defined $observer)
    {
        logline($L_ERROR, "Cannot create observer object.");
        return -1;
    }
    
    # setting signal handler which will kill the observer
    # $SIG{INT} = sub { $observer->end(); };
    $SIG{TERM} = sub { $observer->end(); };
    
    # run the observer
    return $observer->start();
}

# the time checker function
sub runTimeCheck
{
    my $self = shift;

    # get the current time
    my $time = time;

    logline($L_DEBUG, "Run time check.");
    
    # run the time check for each entry in the database
    foreach my $k (keys(%{$self->{db}}))
    {
        my $h = $self->{db}->{$k};
        # if the host is a dynamic host and the status is online
        # check the lease end time of the host
        if($h->getType() eq "dynamic" && $h->getStatus() eq "online" 
            && ($h->getLeaseEndTime() + $tolerance) < $time)
        {
            # is the lease time (+ tolerance time) higher than the current
            # time, than the lease has expired -> the host offline
            logline($L_INFO, "Lease time for dynamic host '" 
                             . $h->getHostname() . "' has expired.");
            $h->offline();
        }
    }
    # set when to run the next time check
    alarm($interval);
}
    
            
sub updateDB
{
    my $self = shift;
    return -1 if !defined $self || ref($self) ne __PACKAGE__;
    
    # extract host specifications from config file
    my $hostdb_n = extract_hosts($self->{conf_file}, $self->{targets_file});
    if(!defined $hostdb_n)
    {
        logline($L_ERROR, "Unable to extract hosts from configuration "
                          . "file.");
        return -1;
    }
    
    logline($L_INFO, "Update host database.");
    
    # integrate the new database hash into the current active one
    if(!merge_db($self->{db}, $hostdb_n))
    {
        logline($L_ERROR, "Cannot merge new database with current one.");
        return -1;
    }
    $self->enableStaticHosts();
    
    return 1;
}

sub enableStaticHosts
{
    my $self = shift;

    foreach my $hk (keys(%{$self->{db}}))
    {
        if($self->{db}->{$hk}->getType() eq "static" &&
            $self->{db}->{$hk}->getStatus() eq "offline")
        {
            $self->{db}->{$hk}->online();
        }
    }
}

# converts the database content to a string
sub getDBasString
{
    my $self = shift;
    my $retval = "";
    my $c = 1;
    
    foreach my $k (keys(%{$self->{db}}))
    {
        $retval .= sprintf("%.2d", $c) . ":\n"
                 . indent($self->{db}->{$k}->getInfo(), "    ", 1)
                 . "\n";
    }
    return $retval;
}

# returns a reference to the database hash
sub getDBRef
{
    my $self = shift;
    return $self->{db};
}

sub cleanup
{
    my $self = shift;
    return;
}

# static non member function

# loads the targets definition
sub load_targets_def
{
    my $filename = $_[0];
    my $lines = read_file($filename);
    my $targets = {};
    
    # unable to read the file
    if(!defined $lines)
    {
        logline($L_ERROR, "Cannot read targets definition file "
                          . "'$filename'.");
        # return an empty targets set
        return {};
    }
    # process each line of the file
    foreach my $l (split(/\n/, $lines))
    {
        # if the line starts with a valid MAC addres
        if($l =~ m/^([A-Fa-f0-9]{1,2}:){5}[A-Fa-f0-9]{1,2}\s+/)
        {
            $l =~ s/\s+/ /g;
            # the rest of the lines are targets definitions
            (my $mac, my @targets_list) = split(/ /, $l);
            # create a reference to the targets list
            $targets->{$mac} = \@targets_list;
        }
    }
    return $targets;
}

# extracts hosts from the DHCP configuration file
sub extract_hosts
{
    my $conf_file = $_[0];
    my $targets_file = $_[1];
    
    if(defined $conf_file && defined $targets_file)
    {
        # load the targets definition from file
        my $targets = load_targets_def($targets_file);

        my $conflines;
        my $parsedconf;
        # read the configuration file and parse it
        if(($conflines = read_file($conf_file)) 
            && ($parsedconf = parse_block($conflines)))
        {
            # extract hosts with empty initial hash
            return extract_hosts_from_block($parsedconf, {}, $targets);
        }
        else
        {
            logline($L_ERROR, "Unable to read or parse DHCP config "
                              . "file '$conf_file'.");
            return undef;
        }
    }
    else
    {
        logline($L_ERROR, "HostDB::DB::extract_hosts: Invalid Argument.");
        return undef;
    }
}
    
# extract host from a parse DHCP config recursiv
sub extract_hosts_from_block
{
    # the current block from which the hosts should be extracted
    my $block = $_[0];
    # the database in which the hosts should be stored
    my $hostdb = $_[1];
    # the targets definitions
    my $targets = $_[2];
    
    # check for valid targets def
    if(!defined $targets || ref($targets) ne "HASH")
    {
        $targets = {};
    }
    
    # process each element in the block
    foreach my $e (@{$block})
    {
        # if the element name is 'host' and the element has a nested block 
        if($e->getName() eq "host" && defined $e->{nested})
        {
            my $host = ();
            # extract the (not official) hostname
            $host->{hostname} = $e->{hostname};
            # set status to offline
            $host->{status} = "offline";

            # process the nested information
            foreach my $he (@{$e->{nested}})
            {
                if($he->getName() eq "hardware" && defined $he->{mac})
                {
                    # extract the MAC address of the host
                    $host->{mac} = $he->{mac};
                }
                elsif($he->getName() eq "fixed_address" 
                    && defined $he->{ip_address})
                {
                    # extract ip address if specified via fixed-address
                    # element and than the host is a static host
                    $host->{type} = "static";
                    $host->{ip_address} = $he->{ip_address};
                }
            }
            
            if(!defined $host->{type})
            {
                # if the type of the host is not already specified, it must
                # be an dynamic host and gets the initial ip address of
                # 0.0.0.0
                $host->{type} = "dynamic";
                $host->{ip_address} = 0;
            }
            
            # a host is only valid if the MAC address is defined
            if(defined $host->{mac})
            {
                # setting targets for this host
                $host->{targets} = $targets->{$host->{mac}};
                
                # create the host in the database
                $hostdb->{$host->{mac}} = HostDB::Host->new($host);
            }
            else
            {
                # ingnoring all hosts where the mac address is not defined
                logline($L_WARN, "Host " . $host->{hostname} . " has no "
                                 . "MAC address. Ignoring it.");
            }
        }
        # XXX WORKAROUND - BUGFIX
        # XXX If the client sends a DHCP discover and the server sends a DHCP
        # XXX offer which the client accepts, the ends time in the dhcpd.leases
        # XXX file is earlier then the starts time. To correct the ends
        # time I need to extract the max_lease_time and send it to the
        # already loaded host package.
        elsif($e->getName() eq "max_lease_time" 
            && defined $e->{maxleasetime})
        {
            # extract the lease time and set it statically for initial
            # DHCP-OFFER-ACCEPT
            $HostDB::Host::max_lease_time = $e->{maxleasetime} 
                if $e->{maxleasetime} > $HostDB::Host::max_lease_time;
        }
        # XXX end of BUGFIX
        elsif(defined $e->{nested})
        {
            # if the element is not a 'host'-element but has nested
            # block process these blocks too
            $hostdb = extract_hosts_from_block($e->{nested}, $hostdb,
                                               $targets);
        }
    }
    # return the hostdb
    return $hostdb;
}

# combines tow databases according to special targets
sub merge_db
{
    # the database which should be updated
    my $hostdb_c = $_[0];
    # the database which is used to update the first one
    my $hostdb_n = $_[1];
   
    # return undef if the parameters are invalid
    return undef 
        if !defined $hostdb_c || !defined $hostdb_n
            || ref($hostdb_c) ne "HASH" 
            || ref($hostdb_n) ne "HASH";
    
    # process each element of the new database
    foreach my $hk (keys(%{$hostdb_n}))
    {
        my $hn = $hostdb_n->{$hk};
        # if there is a host with the same mac address defined in the
        # current database
        if(defined $hostdb_c->{$hk})
        {
            my $hc = $hostdb_c->{$hk};
            if($hc->getStatus() eq "offline" && !$hc->equals($hn))
            {
                # if the status of this host is offline and the entries in the
                # current database and the new database differs - update
                # the host
                logline($L_INFO, "Update offline host " 
                                 . $hc->getHostname()
                                 . " in current host database.");
                $hc->setHostname($hn->getHostname());
                $hc->setIPAddress($hn->getIPAddress());
                $hc->setType($hn->getType());
                $hc->setTargets($hn->getTargets());
            }
            elsif($hc->getStatus() eq "online" && !$hc->equals($hn))
            { 
                # the host is online and differs from new database
                logline($L_INFO, "Update online host " 
                                 . $hc->getHostname()
                                 . " in current host database.");
                # only set online host offline if the type, the
                # ip_address or the targets have been changed
                if($hc->getType() ne $hn->getType()
                    || $hc->getIPAddress() != $hn->getIPAddress() 
                    || !cmp_arrays($hc->getTargets(), $hn->getTargets()))
                {
                    $hc->offline();
                    $hc->setType($hn->getType());
                    $hc->setIPAddress($hn->getIPAddress());
                    $hc->setTargets($hn->getTargets());
                }
                # the hostname can be updated w/o setting host offline
                $hc->setHostname($hn->getHostname());
            }
        }
        else
        {
            # the host was not already defined in the current database, so
            # add it
            logline($L_INFO, "Add host '" . $hn->getHostname()
                             . "' to current host database.");
            $hostdb_c->{$hk} = HostDB::Host->new($hn);
        }
    }

    # process each host of the current database
    foreach my $hk (keys(%{$hostdb_c}))
    {
        # if the host is defined in the current database but not in the
        # new one, remove the host from the database and disable it
        if(!defined $hostdb_n->{$hk})
        {
            # removing host from current db
            logline($L_INFO, "Removing host '" 
                             . $hostdb_c->{$hk}->getHostname()
                             . "' from current host database.");
            $hostdb_c->{$hk}->offline();
            delete $hostdb_c->{$hk};
        }
    }

    # return the updated current database
    return $hostdb_c;
}

1;
