# $Id: subnet.pm,v 1.1 2002/01/06 21:39:04 racon Exp $

package DHCP::subnet;

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
    my $matchStr =
        "\\s*($matchIPv4)\\s+netmask\\s+($matchIPv4)\\s*\\{(.+)\\}\\s*";
    if(defined $_[0] && $_[0] =~  m/^$matchStr$/s)
    {
        $self->{network} = IPv4_str_to_dec($1) or return undef;
        $self->{netmask} = IPv4_str_to_dec($2) or return undef;
        return undef 
            if !IPv4_check_pair($self->{network}, $self->{netmask});
        $self->{nested} = parse_block($3) or return undef;
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
    return "subnet " . IPv4_dec_to_str($self->{network}) . " netmask "
                     . IPv4_dec_to_str($self->{netmask}) . "\n{\n"
                     . indent(get_block($self->{nested}), "    ", 1) 
                     . "}";
}

1;
        
