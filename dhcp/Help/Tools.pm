# $Id: Tools.pm,v 1.2 2002/01/07 18:32:05 racon Exp $

package Help::Tools;

use strict;

# global variables
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $matchIPv4
            $loglevel $L_ERROR $L_INFO $L_WARN $L_DEBUG $validDomainName
            @loadedModules $LT_STDERR $LT_SYSLOG $LT_FILE
            $loginit $logtype $log_fh $progname
           );

# load interface module
use Exporter;

# module version
$VERSION = 0.01;
@ISA = qw(Exporter);

# do not export any names
@EXPORT = qw();
@EXPORT_OK = qw(
IPv4_dec_to_str IPv4_str_to_dec IPv4_check_pair $matchIPv4 load_module 
strip_comments skip_ws indent trim strip_quotes repl_hf get_str_part 
logline loglinennl init_log close_log $L_ERROR $L_INFO $L_WARN $L_DEBUG 
$validDomainName cmp_arrays read_file parse_config_file $LT_STDERR
$LT_SYSLOG $LT_FILE normalize_mac
);

%EXPORT_TAGS = (
    IPv4 => [qw(IPv4_dec_to_str IPv4_str_to_dec IPv4_check_pair $matchIPv4 
                $validDomainName)],
    Strings => [qw(strip_comments skip_ws indent trim strip_quotes
                   repl_hf get_str_part)],
    Modules => [qw(load_module)],
    Logging => [qw(logline loglinennl init_log close_log $L_ERROR $L_INFO 
                   $L_WARN $L_DEBUG $LT_STDERR $LT_SYSLOG $LT_FILE)],
    Arrays => [qw(cmp_arrays)],
    Files => [qw(read_file parse_config_file)],
    MAC => [qw(normalize_mac)]
);

### CODE
    
$validDomainName = "([A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?\\.)*"
                 . "([A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?)";

# MAC section

sub normalize_mac
{
    my $mac = $_[0];
    
    if(defined $mac && $mac =~ m/^([A-Fa-f0-9]{1,2}:){5}[A-Fa-f0-9]{1,2}$/)
    {
        my @e = split(/\:/, $mac) if defined $mac;
        foreach(@e)
        {
            $_ = "0" . $_ if $_ =~ m/^.$/;
            y/[A-Z]/[a-z]/;
        }
        return join(":", @e);
    }
    return undef;
}

# Files section

sub read_file
{
    my $filename = $_[0];
    
    open(FILE, "<$filename") or return undef;
    my $fh = *FILE;
    my $lines = strip_comments(join("", <$fh>));
    close($fh) or return undef;
    
    return $lines;
}

sub parse_config_file
{
    my $filename = $_[0];
    my $conf = ();
    
    my $lines = read_file($filename);
    if(defined $lines)
    {
        foreach my $l (split(/\n/, $lines))
        {
            if($l =~ m/^(\w+)=\"(.*)\"\s*$/)
            {
                $conf->{$1} = $2;
            }
        }
    }
    else
    {
        $conf = undef;
    }
    
    return $conf;
}

# Arrays section

sub cmp_arrays
{
    my $a = $_[0];
    my $b = $_[1];

    return 0 
        if !defined $a || !defined $b 
            || ref($a) ne "ARRAY" || ref($b) ne "ARRAY";
    
    my @A = @{$a};
    my @B = @{$b};
    
    return 0 if $#A != $#B;
    
    my %h;
    @h{@B} = ();
    foreach my $e (@A)
    {
        return 0 if !exists($h{$e});
    }
    
    return 1;
}
    
# Logging section

$L_ERROR = 0;
$L_WARN = 1;
$L_INFO = 2;
$L_DEBUG = 3;

$LT_STDERR = 0;
$LT_SYSLOG = 1;
$LT_FILE = 2;

$loglevel = 2;
$loginit = 0;
$logtype = 0;
$0 =~ m/([^\/]+)$/;
$progname = $1;

sub init_log
{
    if($loginit && $logtype == $LT_SYSLOG)
    {
        closelog();
    }
    elsif($loginit && $logtype == $LT_FILE)
    {
        close($log_fh);
    }
    if(defined $_[0] && $_[0] == $LT_STDERR)
    {
        $logtype = $LT_STDERR;
        $loginit = 1;
    }
    elsif(defined $_[0] && $_[0] == $LT_SYSLOG)
    {
        use Sys::Syslog;
        $logtype = $LT_SYSLOG;
        openlog("fwregd", "pid ndelay", "daemon") or return -1;
        $loginit = 1;
    }
    elsif(defined $_[0] && $_[0] == $LT_FILE && defined $_[2])
    {
        use IO::Handle;
        open(LOGFILE, ">>" . $_[2]) or return -1;
        LOGFILE->autoflush(1);
        $log_fh = *LOGFILE;
        $logtype = $LT_FILE;
        $loginit = 1;
    }
    else
    {
        return -1;
    }
    
    $loglevel = $_[1] if defined $_[1];
    return 0;
}
        
sub loglinennl
{
    if($loginit && $logtype == $LT_STDERR
        && defined $_[0] && defined $_[1] && $_[0] <= $loglevel)
    {
        print STDERR ">>> " . $_[1];
    }
    elsif($loginit && $logtype == $LT_SYSLOG 
        && defined $_[0] && defined $_[1] && $_[0] <= $loglevel)
    {
        my $level = "err";
        $level = "info" if $_[0] == $L_INFO;
        $level = "warn" if $_[0] == $L_WARN;
        $level = "debug" if $_[0] == $L_DEBUG;
        syslog($level, $_[1], ());
    }
    elsif($loginit && $logtype == $LT_FILE && defined $log_fh
        && defined $_[0] && defined $_[1] && $_[0] <= $loglevel)
    {
        my $level = "error";
        $level = "info" if $_[0] == $L_INFO;
        $level = "warn" if $_[0] == $L_WARN;
        $level = "debug" if $_[0] == $L_DEBUG;
        my $str = $_[1];
        $str =~ s/\n$//;
        foreach(split(/\n/, $str))
        {
            print $log_fh scalar(localtime()) . " $progname [$level]: " 
                          . $_ . "\n";
        }
    }
}

sub logline
{
    loglinennl($_[0], $_[1] . "\n") if defined $_[1];
}

sub close_log
{
    if($logtype == $LT_SYSLOG)
    {
        closelog();
    }
    elsif(defined $log_fh)
    {
        close($log_fh);
        $log_fh = undef;
    }
}

# Module section
@loadedModules = ();

sub load_module
{
    my $mod = $_[0];
    my @param = @_[1..$#_];
    my $have = 0;
    foreach(@loadedModules)
    {
        if($_ eq $mod)
        {
            $have = 1;
            last;
        }
    }
    if(!$have)
    {
        logline($L_DEBUG, "Try to load module " . $mod . ".");
        eval "require " . $mod;
        return 0 if $@;
        logline($L_DEBUG, "Module " . $mod . " loaded.");
        push(@loadedModules, $mod);
    }
    $mod->import(@param);
    return 1;
}
 
# Strings section

sub repl_hf
{
    my @a = @_;
    foreach(@a)
    {
        s/-/_/g;
    }
    
    return wantarray ? @a : $a[0];
}

sub indent
{
    my $lines = $_[0];
    my $what = $_[1];
    my $count = $_[2];
    
    for(my $i = 0; $i < $count; $i++)
    {
        $lines =~ s/^/$what/mg;
    }
    return $lines;
}

sub strip_quotes
{
    foreach(@_)
    {
        s/^\s*\"//;
        s/\"\s*$//g;
    }
    
    return wantarray ? @_ : $_[0];
}
    
sub trim
{
    my @v = @_;
    foreach(@v)
    {
        s/^\s+//s;
        s/\s+$//s;
    }

    return wantarray ? @v : $v[0];
}

sub strip_comments
{
    foreach(@_)
    {
        s/^\#.*$//mg;
    }

    return wantarray ? @_ : $_[0];;
}

sub skip_ws
{
    my @chars = @{$_[0]};
    my $count = $_[1];
    
    while($count < $#chars && $chars[$count] =~ m/(\s|\n)/s)
    {
        $count++;
    }
    
    return $count;
}

sub get_str_part
{
    my @chars = @{$_[0]};
    my $count = $_[1];
    my $token = $_[2];
    my $retval = "";
    
    while($count < $#chars && $chars[$count] !~ m/$token/s)
    {
        $retval .= $chars[$count];
        $count++;
    }
    
    return $retval;
}

# IPv4 part

$matchIPv4 = "\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}";

sub IPv4_str_to_dec
{
    my $addr = $_[0];
    
    if(IPv4_is_bit_style($addr))
    {
        my $bitcount = $addr;
        $addr = 0;
        for(my $i = 31; $i >= (32 - $bitcount); $i--)
        {
            $addr |= 1 << $i;
        }
    }
    elsif(IPv4_is_byte_style($addr))
    {
        my @bytes = split(/\./, $addr);
        foreach(@bytes) { return undef if !($_ >= 0 && $_ < 256); } 
        $addr = 0;
        $addr |= $bytes[0] << 24;
        $addr |= $bytes[1] << 16;
        $addr |= $bytes[2] << 8;
        $addr |= $bytes[3];
    }
    else
    {
        $addr = undef;
    }

    return $addr;
}

sub IPv4_dec_to_str
{
    my $addr = $_[0];

    my @bytes;

    $bytes[0] = ($addr >> 24) & 255;
    $bytes[1] = ($addr >> 16) & 255;
    $bytes[2] = ($addr >> 8) & 255;
    $bytes[3] = $addr & 255;
    
    return sprintf("%d.%d.%d.%d", $bytes[0], $bytes[1], 
                   $bytes[2], $bytes[3]);
}

sub IPv4_is_bit_style
{
    return 1 if $_[0] =~ m/^\s*\d+\s*$/;
    return 0;
}

sub IPv4_is_byte_style
{
    return 1 if $_[0] =~ m/^\s*\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\s*$/;
    return 0;
}

sub IPv4_dec_to_bits
{
    my $addr = $_[0];

    my $mask = 0;
    my $bits = 0;
    for(my $i = 31; $i >= 0; $i--)
    {
        $mask |= 1 << $i;
        if($mask == $addr)
        {
            $bits = 32 - $i;
        }
    }
    return $bits;
}
    
sub IPv4_is_netmask
{
    my $addr = $_[0];
    
    my $bits = IPv4_dec_to_bits($addr);
    return 1 if $bits >= 1 && $bits <= 32;
    return 0;
}
            
sub IPv4_check_pair
{
    my $net;
    my $mask;
    
    if(defined $_[0] && !defined $_[1] 
        && defined $_[0]->{netmask} && defined $_[0]->{network})
    {
        $mask = $_[0]->{netmask};
        $net = $_[0]->{network};
    }
    elsif(defined $_[0] && defined $_[1])
    {
        $net = $_[0];
        $mask = $_[1];
    }
    return -2 if !IPv4_is_netmask($mask);
    for(my $i = 31; $i >= 0; $i--)
    {
        return -1
            if(($mask & (1 << $i)) == 0 && ($net & (1 << $i)) != 0)
    }
    
    return 1;
}

1;
