# $Id: Parser.pm,v 1.2 2002/01/07 18:31:04 racon Exp $

package DHCP::Parser;

use strict;
use Help::Tools qw(:Modules :Strings :Logging);

# global variables
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $haveDefault
            $ignoreErrors);

# load interface module
use Exporter;

# module version
$VERSION = 0.01;
@ISA = qw(Exporter);

# do not export any names
@EXPORT = qw();
@EXPORT_OK = qw(get_entry parse_block get_block);

%EXPORT_TAGS = (
    Parser => [qw(get_entry parse_block get_block)]
);

# DHCP::Parser section
sub get_entry
{
    my @chars = @{$_[0]};
    my $pos = $_[1];
    my @res = ();
    my $c = $pos;
    my $level = 0;
    my $end = 0;
    
    while(!$end && $pos <= $#chars)
    {
        if($chars[$pos] eq ";")
        {
            push(@res, $chars[$pos]);
            $end = 1 if $level == 0;
        }
        elsif($chars[$pos] eq "{")
        {
            $level++;
            push(@res, $chars[$pos]);
        }
        elsif($chars[$pos] eq "}")
        {
            $level--;
            push(@res, $chars[$pos]);
            $end = 1 if $level == 0;
        }
        else
        {
            push(@res, $chars[$pos]);
        }
        $pos++;
    }
    return join("", @res);
}

$haveDefault = 0;
$ignoreErrors = 0;

sub ignore_errors
{
    $ignoreErrors = $_[0] if defined $_[0] && ($_[0] == 1 || $_[0] == 0);
}

sub parse_block
{
    my $lines = $_[0];
    my $count = 0;
    my $end = 0;
    my @block;
    
    my @chars = split(//, $lines);
    while(!$end && $count <= $#chars)
    {
        my $str = get_entry(\@chars, $count);
        $count += length($str);
        my $entry;
        if($str =~ m/^\s*([\w-]+)(.*;.*)$/s)
        {
            my $name = "DHCP::" . repl_hf($1);
            my $value = $2;
            if(!load_module($name))
            {
                logline($L_DEBUG, "No module found for entry $name, "
                                 . "using default entry.");
                if(!$haveDefault)
                {
                    if(!load_module("DHCP::default_entry"))
                    {
                        logline($L_ERROR, "Unable to load DHCP::default_entry "
                                          . "module.");
                        return undef;
                    }
                    $haveDefault = 1;
                }
                $entry = "DHCP::default_entry"->new($name, $value);
                if(!defined $entry)
                {
                    logline($ignoreErrors ? $L_WARN : $L_ERROR, 
                            "Cannot create default_entry object.");
                    return undef if !$ignoreErrors;
                }
            }
            else
            {
                $entry = $name->new($value) if defined $name;
                if(!defined $entry)
                {
                    logline($ignoreErrors ? $L_WARN : $L_ERROR, 
                            "Cannot create $name object.");
                    return undef if !$ignoreErrors;
                }
            }
            # print STDERR $entry->getEntry() . "\n";
            push(@block, $entry) if defined $entry;
        }
        elsif($str =~ m/^\s*$/s)
        {
            $end = 1;
        }
        else
        {
            logline($L_ERROR, "Syntax Error\n");
            $end = 1;
            return undef;
        }
    }
    return \@block;
}    

sub get_block
{
    my @block = @{$_[0]};
    my $retval = "";

    foreach my $e (@block)
    {
        $retval .= $e->getEntry() . "\n";
    }

    return $retval;
}

1;
