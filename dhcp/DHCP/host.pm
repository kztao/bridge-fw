# $Id: host.pm,v 1.1 2002/01/06 21:39:04 racon Exp $

package DHCP::host;

use strict;
use Help::Tools qw(:Logging :Strings :IPv4);
use DHCP::Parser qw(:Parser);

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
        && $_[0] =~ m/^\s*($validDomainName)\s*\{(.*)\}\s*$/s)
    {
        $self->{hostname} = $1;
        $self->{nested} = parse_block($6);
        if(!defined $self->{nested})
        {
            logline($L_WARN, "host: Invalid host block content.");
            return undef;
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
    return "host " . $self->{hostname} . "\n{\n"
           . indent(get_block($self->{nested}), "    ", 1) .
           "}";
}

1;
