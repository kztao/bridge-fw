# $Id: Host.pm,v 1.1 2002/01/06 21:39:06 racon Exp $

package HostDB::Host;

use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $max_lease_time
            $onlineScript $offlineScript $defaultTarget);

use Help::Tools qw(:IPv4 :Logging :Arrays);

use Exporter;
@ISA = qw(Exporter);

$VERSION = 0.01;
@EXPORT = qw();
@EXPORT_OK = qw();
%EXPORT_TAGS = ();

$max_lease_time = 120;
$onlineScript = "sh online.sh";
$offlineScript = "sh offline.sh";
$defaultTarget = "DEFAULT_CLIENT";

# create a new Host object
sub new
{
    my $self = {};
    bless($self, shift);

    if(defined $_[0] && ref($_[0]) eq "HASH")
    {
        # constructor with initialization
        my $tmp = $_[0];
        if(defined $tmp->{hostname} && defined $tmp->{mac}
            && defined $tmp->{type})
        {
            # the default status of a new host is offline
            $self->{status} = "offline";
            # set the hostname
            $self->setHostname($tmp->{hostname});
            # set the mac address
            $self->{mac} = $tmp->{mac};
            # set the type
            $self->setType($tmp->{type});
            
            # set the lease start time -> behavior of setLeaseStartTime if
            # $_[0] == undef
            $self->setLeaseStartTime($tmp->{lease_starts});
            # set the lease end time -> behavior of setLeaseEndTime if
            # $_[0] == undef
            $self->setLeaseEndTime($tmp->{lease_ends});

            # set the targets 
            $self->setTargets($tmp->{targets});
            
            # if the host is a static host an ip address must be defined
            if($self->{type} eq "static")
            {
                if(defined $tmp->{ip_address})
                {
                    $self->setIPAddress($tmp->{ip_address});
                }
                else
                {
                    logline($L_ERROR, "Cannot create static host. "
                                      . "IP addressi was not "
                                      . "defined.");
                    return undef;
                }
            }
            else
            {
                # any other host gets a default IP address
                $self->setIPAddress(0);
            }
        }
        else
        {
            # one of the importand arguments is missing
            logline($L_ERROR, "Cannot create host object. Required "
                              . "argument missing.");
            return undef;
        }
    }
    elsif(defined $_[0] && ref($_[0]) eq __PACKAGE__)
    {
        # copy constructor
        my $tmp = $_[0];
        $self->{hostname} = $tmp->{hostname};
        $self->{ip_address} = $tmp->{ip_address};
        $self->{mac} = $tmp->{mac};
        $self->{type} = $tmp->{type};
        $self->{status} = $tmp->{status};
        $self->{lease_starts} = $tmp->{lease_starts};
        $self->{lease_ends} = $tmp->{lease_ends};
        $self->{targets} = $tmp->{targets};
    }
    else
    {
        logline($L_ERROR, "Cannot create host object. Invalid argument.");
        return undef;
    }
    return $self;
}

# set online status for the host
sub online
{
    my $self = shift;

    my $targets = "none";
    
    $targets = join(", ", @{$self->{targets}}) 
        if defined $self->{targets} && ref($self->{targets}) eq "ARRAY";
    
    # only set online status if the host is offline
    if($self->{status} eq "offline")
    {
        logline($L_INFO, "Setting host '" . $self->{hostname} 
                         . "' to status online.");
        $self->{status} = "online";
        if(defined $self->{targets} && scalar(@{$self->{targets}}) > 0)
        {
            foreach my $t (@{$self->{targets}})
            {
                loglinennl($L_INFO, "Host '" . $self->{hostname} . "': "
                                 . "Enable target $t...");
                my $retval = system("$onlineScript " . $self->{mac} 
                                    . " " . $self->{ip_address} . " $t");
                if($retval != 0)
                {
                    logline($L_INFO, "failed");
                }
                else
                {
                    logline($L_INFO, "ok");
                }
            }
        }
        else
        {
            loglinennl($L_INFO, "Host '" . $self->{hostname} . "': "
                             . "Enable target $defaultTarget...");
            my $retval = system("$onlineScript " . $self->{mac} 
                                . " " . $self->{ip_address}
                                . " $defaultTarget");
            if($retval != 0)
            {
                logline($L_INFO, "failed");
            }
            else
            {
                logline($L_INFO, "ok");
            }
        }
    }
}

# set offline status for the host
sub offline
{
    my $self = shift;
    
    my $targets = "none";
    $targets = join(", ", @{$self->{targets}}) 
        if defined $self->{targets} && ref($self->{targets}) eq "ARRAY";

    # set the host online offline if it is online
    if($self->{status} eq "online")
    {
        logline($L_INFO, "Setting host '" . $self->{hostname} 
                         . "' to status offline. Targets are: $targets");
        $self->{status} = "offline";
        if(defined $self->{targets} && scalar(@{$self->{targets}}) > 0)
        {
            foreach my $t (@{$self->{targets}})
            {
                loglinennl($L_INFO, "Host '" . $self->{hostname} . "': "
                                 . "Disable target $t...");
                my $retval = system("$offlineScript " . $self->{mac} 
                                    . " " . $self->{ip_address} . " $t");
                if($retval != 0)
                {
                    logline($L_INFO, "failed");
                }
                else
                {
                    logline($L_INFO, "ok");
                }
            }
        }
        else
        {
            loglinennl($L_INFO, "Host '" . $self->{hostname} . "': "
                             . "Disable target $defaultTarget...");
            my $retval = system("$offlineScript " . $self->{mac} 
                                . " " . $self->{ip_address}
                                . " $defaultTarget");
            if($retval != 0)
            {
                logline($L_INFO, "failed");
            }
            else
            {
                logline($L_INFO, "ok");
            }
        }
    }
}

# set the targets
sub setTargets
{
    my $self = shift;

    if(defined $_[0] && ref($_[0]) eq "ARRAY")
    {
        # check if it is a reference to an array
        $self->{targets} = $_[0];   
    }
    else
    {
        # otherwise sent an empty array
        $self->{targets} = [];
    }
}

# returns the reference to the targets def array
sub getTargets
{
    my $self = shift;
    return $self->{targets};
}

# set the ip address
sub setIPAddress
{
    my $self = shift;
    
    if($self->{status} eq "offline")
    {
        # can only set ip address if the host is offline
        $self->{ip_address} = $_[0] if defined $_[0];
    }
    else
    {
        logline($L_WARN, "Cannot change IP address of an online host.");
    }
}

# set the host type
sub setType
{
    my $self = shift;
    if($self->{status} eq "offline")
    {
        # can only set the host type if the host is offline
        $self->{type} = $_[0] if defined $_[0];
    }
    else
    {
        logline($L_WARN, "Cannot chnage type of an online host.");
    }
}

# sets the hostname
sub setHostname
{
    my $self = shift;
    $self->{hostname} = $_[0] if defined $_[0];
}

# returns the status of the host
sub getStatus
{
    my $self = shift;
    return $self->{status};
}

# returns the IP address of the host
sub getIPAddress
{
    my $self = shift;
    return $self->{ip_address};
}

# returns the MAC address of the host
sub getMACAddress
{
    my $self = shift;
    return $self->{mac};
}

# returns the hostname of the host
sub getHostname
{
    my $self = shift;
    return $self->{hostname};
}

# returns the type of the host
sub getType
{
    my $self = shift;
    return $self->{type};
}

# returns the lease start time
sub getLeaseStartTime
{
    my $self = shift;
    return $self->{lease_starts};
}

# returns the lease end time
sub getLeaseEndTime
{
    my $self = shift;
    return $self->{lease_ends};
}

# sets the lease start time
sub setLeaseStartTime
{
    my $self = shift;
    
    if(!defined $_[0])
    {
        # if the argument is not defined set the lease start time to 0
        $self->{lease_starts} = 0;
    }
    elsif($_[0] <= time)
    {
        # if the argument is lower or equal the current time the set it to
        # the lease start time
        $self->{lease_starts} = $_[0];
    }
    else
    {
        # in any other case the argument is wrong and the lease time is
        # setted to the current time
        logline($L_WARN, "HostDB::Host: Lease start time must be now "
                         . "or earlier.");
        $self->{lease_starts} = time;
    }
}

sub setLeaseEndTime
{
    my $self = shift;
    
    if(!defined $_[0])
    {
        # if the argument is not defined the lease end time is the same
        # than the lease start time
        $self->{lease_ends} = $self->{lease_starts};
    }
    # XXX WORKAROUND - BUGFIX
    # XXX If the client sends a DHCP discover and the server sends a DHCP
    # XXX offer which the client accepts, the ends time in the dhcpd.leases
    # XXX file is earlier then the starts time. I measuered an offset of 1
    # XXX second so I guess checking within 10 seconds should be enough 
    elsif($_[0] < $self->{lease_starts} 
        && ($_[0] - $self->{lease_starts}) <= 10)
    {
        logline($L_WARN, "DHCP-DISCOVER-OFFER ENDS before STARTS BUGFIX"
                         . " - Using lease time '$max_lease_time'");
        $self->{lease_ends} = $self->{lease_starts} + $max_lease_time;
    }
    # XXX end of BUGFIX
    elsif($_[0] >= $self->{lease_starts})
    {
        # if the argument is higher or equal to the start lease time, it is
        # a valid end lease time
        $self->{lease_ends} = $_[0];
    }
    else
    {
        # any other arguement is invalid and the end time is setted to the
        # start time
        logline($L_WARN, "HostDB::Host: Lease end time must be later "
                         . "than start time.");
        $self->{lease_ends} = $self->{lease_starts};
    }
}

# returns infos about the host as a string
sub getInfo
{
    my $self = shift;
    return sprintf(  "Hostname:           %s\n"
                   . "MAC address:        %s\n"
                   . "IP address:         %s\n"
                   . "Type:               %s\n"
                   . "Status:             %s\n"
                   . "Lease starts (GMT): %s\n"
                   . "Lease ends (GMT):   %s\n", 
                   $self->{hostname}, $self->{mac},
                   IPv4_dec_to_str($self->{ip_address}),
                   $self->{type},
                   $self->{status},
                   scalar(gmtime($self->{lease_starts})),
                   scalar(gmtime($self->{lease_ends})));
}

# compares the current host which the host specified in the argument
sub equals
{
    my $self = shift;
    my $h = $_[0];

    if(defined $h && ref($h) eq __PACKAGE__)
    {
        return 1 
            # the host are equal if their hostnames are the same
            if $self->getHostname() eq $h->getHostname() 
                # and they are either dynamic or the ip addresses are
                # equal
                && ($self->getType() eq "dynamic" 
                        || $self->getIPAddress() eq $h->getIPAddress())
                # and their mac addresses are the same
                && $self->getMACAddress() eq $h->getMACAddress()
                # their type is the same
                && $self->getType() eq $h->getType()
                # and their targets are the same
                && cmp_arrays($self->getTargets(), $h->getTargets());
        # otherwise they are not equal        
        return 0;
    }
    return 0;
}

1;
