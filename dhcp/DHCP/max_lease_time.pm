# $Id: max_lease_time.pm,v 1.1 2002/01/06 21:39:04 racon Exp $

package DHCP::max_lease_time;

use strict;
use Help::Tools qw(:Logging :Strings);

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
    if(defined $_[0] && length($_[0]) > 0 
        && $_[0] =~ m/^\s*(\d+)\s*;.*$/s)
    {
        $self->{maxleasetime} = $1;
        return undef if $self->{maxleasetime} <= 0;
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
    return "max-lease-time " . $self->{maxleasetime} . ";";
}

1;
