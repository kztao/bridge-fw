# $Id: abandoned.pm,v 1.1 2002/01/06 21:39:04 racon Exp $

package DHCP::abandoned;

use strict;

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
    if(defined $_[0] && $_[0] =~ m/^\s*;$/s)
    {
        # do nothing here
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
    return "abandoned;"; 
}

1;
