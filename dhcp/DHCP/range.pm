# $Id: range.pm,v 1.1 2002/01/06 21:39:04 racon Exp $

package DHCP::range;

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
        && $_[0] =~ m/^\s*([\w-]*)\s+($matchIPv4)(\s*($matchIPv4))?\s*;.*$/s)
    {
        # XXX 
        # - check if range is in subnet
        # - check if start address is lower than end address
         
        $self->{additional} = $1 if length $1;
        my $start = IPv4_str_to_dec($2);
        return undef if !defined $start;
        
        my $end = IPv4_str_to_dec($4) if defined $4;
        
        $self->{start} = $start;
        $self->{end} = $end;
    }
    else
    {
        return undef;
    }
    return $self;
}

sub getStartAddr
{
    my $self = shift;

    return IPv4_dec_to_str($self->{start});
}

sub getEndAddr
{
    my $self = shift;

    return (defined $self->{end} ? IPv4_dec_to_str($self->{end}) : undef);
}

sub getEntry
{
    my $self = shift;
    return "range " 
           . (defined $self->{additional} ? $self->{additional}." ":"")
           . $self->getStartAddr() 
           . (defined $self->{end} ? " " . $self->getEndAddr() : "") 
           . ";";
}

1;
