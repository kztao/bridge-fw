#$Id: option_default.pm,v 1.1 2002/01/06 21:39:04 racon Exp $

package DHCP::option_default;

use strict;
use Help::Tools qw(:Strings);

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

    if(defined $_[0] && length(trim($_[0])) && defined $_[1])
    {
        $self->{name} = trim($_[0]);
        $self->{value} = trim($_[1]);
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

    return $self->{name} . " " . $self->{value};
}

1;
