# $Id: fixed_address.pm,v 1.1 2002/01/06 21:39:04 racon Exp $

package DHCP::fixed_address;

use strict;
use Help::Tools qw(:Logging :Strings :IPv4);
#use Socket;

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
    
    if(defined $_[0] && length($_[0]) > 0) 
    {
        if($_[0] =~ m/^\s*($matchIPv4)\s*;.*$/s)
        {
            $self->{ip_address} = IPv4_str_to_dec($1);
            return undef if !defined $self->{ip_address};
        }
        elsif($_[0] =~ m/^\s*($validDomainName)\s*;.*$/s)
        {
            logline($L_WARN, "Usage of hostname in fixed-address element not yet "
                    . "supported.");
            return undef;
#            my $tmp = inet_aton($1) or return undef;
#            $self->{ip_address} = IPv4_dec_to_str(inet_ntoa($tmp));
#            return undef if !defined $self->{ip_address};
        }
        else
        {
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
    return "fixed-address " . IPv4_dec_to_str($self->{ip_address}) . ";";
}

1;
