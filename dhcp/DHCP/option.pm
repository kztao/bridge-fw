# $Id: option.pm,v 1.1 2002/01/06 21:39:04 racon Exp $

package DHCP::option;

use strict;
use Help::Tools qw(:Strings :Logging :Modules);

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

#@validOptions = ("routers", "domain-name-server", "domain-name",
#                 "broadcast-address", "nis-domain", "nis-servers",
#                 "subnet-mask");

### CODE

# the constructor for the deny object
 
sub new
{
    my $self = DHCP::baseclass->new(__PACKAGE__);
    
    bless($self, shift);
    if(defined $_[0] && length($_[0]) > 0 
        && $_[0] =~ m/^\s*([\w-]+)(\s+[^;]*);.*$/s)
    {
        my $oname = $1;
        my $value = $2;
        my $omod = "DHCP::option_" . repl_hf($oname);
        if(load_module($omod))
        {
            $self->{option} = $omod->new($value) if defined $omod;
            return undef if !defined $self->{option};
        }
        else
        {
            logline($L_DEBUG, "Do not have a module for option $oname. "
                              . "Using option_default module.");
            load_module("DHCP::option_default") or return undef;
            $self->{option} = DHCP::option_default->new($oname, $value)
                or return undef;
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
    return "option " . $self->{option}->getEntry() . ";"; 
}

1;
