# $Id: option_routers.pm,v 1.1 2002/01/06 21:39:04 racon Exp $

package DHCP::option_routers;

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

# the constructor for the deny object
 
sub new
{
    my $self = DHCP::baseclass->new(__PACKAGE__);
    bless($self, shift);
    if(defined $_[0] && length(trim($_[0])) > 0)
    {
        my @v_routers = split(/,/, trim($_[0]));
        my @routers = ();
        foreach my $r (@v_routers)
        {
            $r = trim($r);
            if($r =~ m/^$matchIPv4$/)
            {
                push(@routers, $r);
#                my $dec_r = IPv4_str_to_dec($r);
#                if(defined $dec_r)
#                {
#                    push(@routers, $dec_r);
#                }
#                else
#                {
#                    logline($L_WARN, "option routers: Invalid IP "
#                                     . "address.");
#                    return undef;
#                }
            }
            else
            {
                push(@routers, $r);
            }
        }
        if($#routers >= 0)
        {
            $self->{routers} = \@routers;
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
    
    foreach my $r (@{$self->{routers}})
    {
        if($r =~ m/^\d+$/)
        {
            $r = IPv4_dec_to_str($r);
        }
    }
    return "routers " . join(", ", @{$self->{routers}});
}

1;
