# $Id: range.pm,v 1.1 2002/01/06 21:39:04 racon Exp $

package DHCP::binding;

use strict;
use Help::Tools qw(:IPv4);

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

# the constructor for the range object
 
sub new
{
    my $self = DHCP::baseclass->new(__PACKAGE__);
    
    bless($self, shift);
    if(defined $_[0] && length($_[0]) > 0 
        && $_[0] =~ m/^\s*state\s*([\w-]*)\s*;.*$/s)
    {
        $self->{state} = $1 if length $1;
    }
    else
    {
        return undef;
    }
    return $self;
}

sub getState
{
    my $self = shift;

    return $self->{state};
}

sub getEntry
{
    my $self = shift;
    return "binding state " . $self->{state} . ";";
}

1;
