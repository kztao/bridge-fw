# $Id: lease.pm,v 1.1 2002/01/06 21:39:04 racon Exp $

package DHCP::lease;

use strict;
use Help::Tools qw(:IPv4 :Strings);
use DHCP::Parser qw(:Parser);
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

$VERSION = 0.01;

use Exporter;
use DHCP::baseclass;
@ISA = qw(DHCP::baseclass Exporter);

@EXPORT = qw();
@EXPORT_OK = qw();
%EXPORT_TAGS = ();

sub new
{
    my $self = DHCP::baseclass->new(__PACKAGE__);
    bless($self, shift);
    if(defined $_[0] 
        && $_[0] =~ m/^\s*($matchIPv4)\s+\{(.+)\}\s*$/s)
    {
        $self->{address} = IPv4_str_to_dec($1) or return undef;
        $self->{nested} = parse_block($2) or return undef;
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
    return "lease " . IPv4_dec_to_str($self->{address}) 
           . "\n{\n" . indent(get_block($self->{nested}), "    ", 1) 
           . "}";
}

1;
