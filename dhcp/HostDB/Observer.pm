# $Id: Observer.pm,v 1.1 2002/01/06 21:39:06 racon Exp $

package HostDB::Observer;

use strict;
use vars qw(@EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION @ISA $end);
use Help::Tools qw(:Logging :Strings :IPv4);
use DHCP::Parser qw(:Parser);
use HostDB::DB;
use Fcntl qw(O_RDONLY);
use DHCP::starts;

use Exporter;
@ISA = qw(Exporter);

@EXPORT = qw();
@EXPORT_OK = qw();
%EXPORT_TAGS = ();

# create a new observer object
sub new
{
    my $self = {};
    bless($self, shift);

    if(defined $_[0] && ref($_[0]) eq "HostDB::DB")
    {
        # a backreference to the hostdb
        $self->{hostdb} = $_[0];
        # the filename of the lease file
        $self->{leases_file} = $self->{hostdb}->{leases_file};
    }
    else
    {
        logline($L_ERROR, "HostDB::Observer: Invalid Agrument.");
        return undef;
    }
    return $self;
}

# wrapper to start the observer function
sub start
{
    my $self = shift;
    return $self->observer();
}

sub observer
{
    my $self = shift;

    # the filename of the file to observe
    my $filename = $self->{leases_file};
    # the file handle
    my $fh;
    # the current position in the file
    my $pos = 0;
    # the size of the file
    my $size = 0;
    # indicator if the file should be reopened
    my $reopen = 1;
    # the inode number of the file
    my $inode = 0;

    # the string buffer
    my $str = "";
    
    logline($L_INFO, "HostDB::Observer: Observer is running.");
    
    while(!$end)
    {
        # open file if necessary
        if($reopen)
        {
            logline($L_INFO, "HostDB::Observer: Reopen leases file.");
            sysopen(FILE, $filename, O_RDONLY) or return -1;
            $fh = *FILE;
            $pos = 0;
            $reopen = 0;
            $inode = (stat($fh))[1];
            return error_fh($fh, -2) if !defined $inode;
        }

        # get file size
        $size = (stat($fh))[7];
        return error_fh($fh, -2) if !defined $size;
    
        # if the current position higher than file size 
        # reread the whole file
        $pos = 0 if $pos > $size;
        
        # set the file postion
        sysseek($fh, $pos, 0) or return error_fh($fh, -3);
        
        my $line;
        
        # read the lines
        while($line = <$fh>)
        {
            # add the length to the current file position
            $pos += length($line);
            # strip all comments from the line
            $str .= strip_comments($line);
            $str =~ s/uid \".*\";//g;
            $str =~ s/client-hostname \".*\";//g;
            # match all lease blocks in $str
            while($str =~ s/(\s*lease[^\{]+\{[^\}]+\})//sg)
            {
                # if a lease block was found parse it and send it to
                # setStatus which updates the status of the host the lease
                # was assigned to
                # print $1 ."\n\n";
                if(!$self->setStatus(parse_block($1)))
                {
                    logline($L_WARN, "HostDB::Observer: Cannot set "
                                     . "status.");
                }
                
                # remove allready read block from string
                #my $tmpstr = $1;
                #print $tmpstr ."\n\n";
                #$tmpstr =~ s/uid \".*\";/uid \"\.\*\";/g;
                #$tmpstr =~ s/\\/\\\\/g;
                # $tmpstr =~ s/\'/\\\'/g;
                # $tmpstr =~ s/\"/\\\"/g;
                #$tmpstr =~ s/\?/\\\?/g;
                #$tmpstr =~ s/\(/\\\(/g;
                #$tmpstr =~ s/\)/\\\)/g;
                #$tmpstr =~ s/\|/\\\|/g;
                #$tmpstr =~ s/\[/\\\[/g;
                #$tmpstr =~ s/\{/\\\{/g;
                #$tmpstr =~ s/\^/\\\^/g;
                #$tmpstr =~ s/\$/\\\$/g;
                #$tmpstr =~ s/\*/\\\*/g;
                #$tmpstr =~ s/\+/\\\+/g;
                #$tmpstr =~ s/\./\\\./g;
                # print $str ."\n\n";
                #print $tmpstr . "\n\n";
                #$str =~ s/^$tmpstr//s or print "Geht nicht.\n";
                # XXX debug thing
                # print $self->{hostdb}->getDBasString();
            }
        }
    
        # get size of file
        $size = (stat($fh))[7];
        return error_fh($fh, -2) if !defined $size;

        # check size and inode of file
        # if the inode-number has been changed a new file was created or
        # the file was deleted
        my @stat;
        while(!$end && (@stat = stat($filename)) && $size == $stat[7] 
            && $inode == $stat[1])
        {
            sleep(1);
        }
    
        # if file does not exists anymore
        if(!-e $filename)
        {
            # close file anyway
            close($fh) or return -4;
            $reopen = 1;
            
            # wait 3 seconds, maybe it comes back
            sleep(3);
            if(!-e $filename)
            {
                # it is still not there so just end
                logline($L_ERROR, "The leases file has disappeared.");
                $end = 1;
            }
        }
        elsif((stat($filename))[1] != $inode)
        {
            # if a new file was created reopen it and close the old FH
            close($fh) or return -4;
            $reopen = 1;
        }
    }
    return 0;
}

# set the status of the host the lease was assigned to
sub setStatus
{
    my $self = shift;
    # the parsed lease block
    my $block = $_[0];
    
    # must be a reference to an array
    if(!defined $block || ref($block) ne "ARRAY")
    {
        logline($L_ERROR, "HostDB::Observer: "
                          . "Invalid argument.");
        return 0;
    }
    
    # the empty host
    my $host = ();
    
    # XXX check if it is really a lease block
    # XXX if(ref($block->[0]) eq "DHCP::lease") 
   
    # set the ip address of the host
    $host->{ip_address} = $block->[0]->{address};
    foreach my $e (@{$block->[0]->{nested}})
    {
        if($e->getName() eq "hardware")
        {
            # set mac addess
            $host->{mac_address} = $e->{mac};
        }
        elsif($e->getName() eq "starts")
        {
            # set lease start time
            $host->{lease_starts} = $e->{t_epoch};
        }
        elsif($e->getName() eq "ends")
        {
            # set lease end time
            $host->{lease_ends} = $e->{t_epoch};
        }
        elsif($e->getName() eq "binding")
        {
            # indicates that the IP address has abandoned
            if($e->getState() eq "abandoned")
            {
                $host->{abandoned} = 1;
            }
            else
            {
                $host->{abandoned} = 0;
            }
        }
    }
    
    if(defined $host->{abandoned} && $host->{abandoned} == 1)
    {
        # if ip address has abandoned
        # XXX disable all host which have this ip-address
        logline($L_INFO, "HostDB::Observer: "
                         . "IP address " 
                         . IPv4_dec_to_str($host->{ip_address})
                         . " abandoned.");
    }
    elsif(!defined $host->{mac_address})
    {
        # if the host has no mac address
        logline($L_WARN, "HostDB::Observer: "
                         . "MAC address not available.");
        # XXX emergancy code
    }
    else
    {
        # host with mac address went online
        my $mac = $host->{mac_address};
        
        if(defined $self->{hostdb}->{db}->{$mac})
        {
            # host is defined in database
            my $h = $self->{hostdb}->{db}->{$mac};
            
            if($h->getType() eq "dynamic")
            {
                # host is a dynamic host
                if($h->getLeaseStartTime() < $host->{lease_starts})
                {
                    # lease times differs force the update of the lease
                    # times
                    $h->setLeaseStartTime($host->{lease_starts});
                    $h->setLeaseEndTime($host->{lease_ends});
                    
                    # if the ip address of the host has changed set the
                    # host offline and change it
                    if($h->getIPAddress() != $host->{ip_address})
                    {
                        # IP address has also changed
                        $h->offline();
                        $h->setIPAddress($host->{ip_address});
                    }
                    # set the host online in any case
                    $h->online(); 
                }
            }
            elsif($h->getType() eq "static")
            {
                # host is a static host
                logline($L_INFO, "HostDB::Observer: "
                                 . "Ignoring static host, should be "
                                 . "already online.");
            }
        }
        else
        {
            logline($L_WARN, "HostDB::Observer: "
                             . "Unknown hosts was entering network."
                             . " MAC address: $mac");
            # XXX Emergancy reaction here
        }
    }
    
    return 1;
}

# the function which is called to cancel the observer
sub end
{
    $end = 1;
}

# closes a filehandle on error and returning the errorcode
sub error_fh
{
    my $fh = $_[0];
    my $errno = $_[1];

    close($fh) or return -4;
    return $errno;
}

1;
