# $Id: ends.pm,v 1.1 2002/01/06 21:39:04 racon Exp $

package DHCP::ends;

use strict;
use Help::Tools qw(:Strings :Logging);
use Time::Local qw(timegm_nocheck);

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
    my $match = "\\s*(\\d)\\s+(\\d{4})\\/(\\d{1,2})\\/(\\d{1,2})\\s+"
              . "(\\d{1,2}):(\\d{1,2}):(\\d{1,2})\\s*;\\s*";
    
    bless($self, shift);
    if(defined $_[0] && $_[0] =~ m/^$match$/s)
    {
        # XXX check for valid values in date
        $self->{t_epoch} = timegm_nocheck($7,$6,$5,$4,$3 - 1,$2);        
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
    my @date = gmtime($self->{t_epoch});
    
    return "ends " 
           . sprintf("%d %.4d/%.2d/%.2d %.2d:%.2d:%.2d",
                     $date[6],
                     $date[5] + 1900,
                     $date[4] + 1,
                     $date[3],
                     $date[2],
                     $date[1],
                     $date[0])
           . ";";
}

1;
