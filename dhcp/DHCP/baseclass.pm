# $Id: baseclass.pm,v 1.1 2002/01/06 21:39:04 racon Exp $

package DHCP::baseclass;

use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

use Exporter;
@ISA = qw(Exporter);

@EXPORT = qw();
@EXPORT_OK = qw();
%EXPORT_TAGS = ();

$VERSION = 0.01;

sub new
{
    my $self = {};
    bless($self, shift);
    
    my $tmp = __PACKAGE__;
    $tmp = $_[0] if defined $_[0];
    $tmp =~ s/.*::([^:]+)$/$1/;
    
    $self->{class_name} = $tmp;
    return $self;
}
    
sub getName
{
    my $self = shift;
    return $self->{class_name};
}

1;
