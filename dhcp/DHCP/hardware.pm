# $Id: hardware.pm,v 1.1 2002/01/06 21:39:04 racon Exp $

package DHCP::hardware;

use strict;
use Help::Tools qw(:Logging :Strings :MAC);

# global variables
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

# load interface module
use Exporter;
use DHCP::baseclass;

# module version
$VERSION = 0.01;
@ISA = qw(DHCP::baseclass Exporter);

# do not export any names
@EXPORT = qw();
@EXPORT_OK = qw();
%EXPORT_TAGS = ();

### CODE

sub new
{
    my $self = DHCP::baseclass->new(__PACKAGE__);
    
    bless($self, shift);
    if(defined $_[0] 
        && $_[0] =~ m/^\s*([\w-]+)\s+(.*)\s*;\s*$/s)
    {
        $self->{type} = $1;
        $self->{mac} = normalize_mac($2);
        if($self->{type} eq "ethernet")
        {
            if(!defined $self->{mac})
            {
                logline($L_WARN, "hardware: Invalid ethernet address.");
                return undef;
            }
        }
    }
    else
    {
        return undef;
    }
    return $self;
}

sub getEntry
{
    my $self = shift;
    return "hardware " . $self->{type} . " " . $self->{mac} . ";";
}

1;
