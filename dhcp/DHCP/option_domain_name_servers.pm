# $Id: option_domain_name_servers.pm,v 1.1 2002/01/06 21:39:04 racon Exp $

package DHCP::option_domain_name_servers;

use strict;
use Help::Tools qw(:Strings :Logging :IPv4);

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
    if(defined $_[0] && length(trim($_[0])) > 0)
    {
        my @v_servers = split(/,/, trim($_[0]));
        my @servers = ();
        foreach my $s (@v_servers)
        {
            $s = trim($s);
            if($s =~ m/^$matchIPv4$/)
            {
                push(@servers, $s);
#                my $dec_s = IPv4_str_to_dec($s);
#                if(defined $dec_s)
#                {
#                    push(@servers, $dec_s);
#                }
#                else
#                {
#                    logline($L_WARN, "option domain-name-servers: "
#                                     . "Invalid IP address.");
#                    return undef;
#                }
            }
            else
            {
                push(@servers, $s);
            }
        }
        if($#servers >= 0)
        {
            $self->{servers} = \@servers;
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
    
#    foreach my $s (@{$self->{servers}})
#    {
#        if($s =~ m/^\d+$/)
#        {
#            $s = IPv4_dec_to_str($s);
#        }
#    }
    return "domain-name-servers " . join(", ", @{$self->{servers}});
}

1;
