# $Id: deny.pm,v 1.1 2002/01/06 21:39:04 racon Exp $

package DHCP::deny;

use strict;
use Help::Tools qw(:Strings :Logging);

# global variables
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION %denyValues);

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

%denyValues = (
    "unknown-clients" => "Deny all clients which do not have a host "
                         . "entry in this section.",
    "bootp" => "Do not allow bootp for this sections."
);

### CODE

# the constructor for the deny object
 
sub new
{
    my $self = DHCP::baseclass->new(__PACKAGE__);
    
    bless($self, shift);
    if(defined $_[0])
    {
        my $val = $_[0];
        foreach my $k (keys(%denyValues))
        {
            if($val =~ m/^\s*($k)\s*;.*$/s)
            {
                $self->{value} = $k;
                last;
            }
        }
        if(!defined $self->{value})
        {
            logline($L_INFO, "Unknow value \"$val\" for deny command. Ignoring.");
            $self->{unknown} = $val;
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
    return "deny " 
           . (defined $self->{value} ? $self->{value} : $self->{unknown} ) 
           . ";";
}

1;
