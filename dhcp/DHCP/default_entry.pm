# $Id: default_entry.pm,v 1.1 2002/01/06 21:39:04 racon Exp $

package DHCP::default_entry;

use strict;
use Help::Tools qw(:Strings :Logging);
use DHCP::Parser qw(:Parser);

# define global variables
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

# load interface modu;e
use Exporter;
use DHCP::baseclass;
$VERSION = 0.01;

# this module is a Exporter
@ISA = qw(DHCP::baseclass Exporter);

@EXPORT = qw();
@EXPORT_OK = qw();
%EXPORT_TAGS = ();

# contructor for the default entry which just takes the entry without any
# changes
# 
sub new
{
    my $self = DHCP::baseclass->new(__PACKAGE__);
    bless($self, shift);

    $self->{name} = trim($_[0]);
    $self->{name} =~ s/^.*:://;
    $self->{name} =~ s/_/-/g;
    if(defined $_[1] && length($_[1]) > 0)
    {
        if($_[1] =~ m/^\s*([^\{]*)\{(.*)\}\s*$/s)
        {
            $self->{value} = trim($1);
            $self->{nested} = parse_block($2);
            if(!defined $self->{nested})
            {
                logline($L_WARN, "default_entry: Invalid block.");
                return undef;
            }
        }
        elsif($_[1] =~ m/^\s*(.*)\s*;\s*$/)
        {
            $self->{value} = $1;
        }
        else
        {
            print "Return 1 " . $_[1] . "\n";
            return undef;
        }
    }
    else
    {
        print "Return 2\n";
        return undef;
    }
    return $self;
}

sub getEntry 
{
    my $self = shift;

    return $self->{name} . " " . $self->{value} . ";" 
        if !defined $self->{nested};
    
    return $self->{name} . " " . $self->{value} . "\n{\n"
           . indent(get_block($self->{nested}), "    ", 1) .
           "}" if defined $self->{nested};
}

1;
