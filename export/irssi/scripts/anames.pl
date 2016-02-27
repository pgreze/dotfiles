# anames.pl
# Irssi script that adds an /anames command, a clone of /names, with away nicks
# grayed out. (use /dowho to do a /who on all channels to update away
# information)
# 
# This is my first real perl script as well as my first script for irssi. Send
# suggestions, corrections, ideas to the address below.
# 
# Thanks to Dirm and Chris62vw for the perl help and coekie for writing the
# evil code to sort the nicklist by the alphabet and rank in nicklist.pl
#
# 1.2   - It seems that redirected events will not pass through the internal
#         mechanisms that update user information (like away states). So, it
#         /dowho and the periodic execution of the command has been disabled.
#         /anames will still work, but new away information will need to be
#         obtained by executing a /who on a channel.
#         If you can make redirection (execute a /who without the information
#         spilling to the status window) work, let me know so I can fix the
#         script.
#
# 1.0.1 - Fixed row-determining and max-nick-length code, changed command_add
#         calls to refs instead of names.
#
# 1.0   - Added timer for periodic /who of all channels
#
# 0.9   - Initial test release

use strict;
use Irssi;
use POSIX;
#use Data::Dumper;
use vars qw($VERSION %IRSSI);
$VERSION="1.2";
%IRSSI = (
    authors     => "Matt 'f0rked' Sparks",
    contact     => "root\@f0rked.com",
    name        => "anames",
    description => "displays something similar to /names with away nicks colored",
    license     => "GPLv2",
    url         => "http://f0rked.com",
    changed     => "2005-12-04",
    commands    => "anames"
);

# How often to do a /who of all channels (in seconds)
#my $who_timer = 300;

my $tmp_chan;

sub cmd_anames {
    my $server = Irssi::active_server();
    my $channel = ($_[0] ne "") ? 
        Irssi::Server::channel_find($server,$_[0]) :
        Irssi::active_win->{active};
    my $chan = $channel->{'name'};
    my $nick;
    if (!$channel || (ref($channel) ne 'Irssi::Irc::Channel' && ref($channel) ne 'Irssi::Silc::Channel') || $channel->{'type'} ne 'CHANNEL' || ($channel->{chat_type} ne 'SILC' && !$channel->{'names_got'}) ) {
        # no nicklist
        Irssi::print ("Not joined to any channel", MSGLEVEL_CLIENTERROR);
    }
    else {
        # Loop through each nick and display
        my @nicks;
        my $ops=0; my $halfops=0; my $voices=0; my $normal=0; my $away=0;
        foreach my $nick (sort {(($a->{'op'}?'1':$a->{'halfop'}?'2':$a->{'voice'}?'3':'4').lc($a->{'nick'}))
                    cmp (($b->{'op'}?'1':$b->{'halfop'}?'2':$b->{'voice'}?'3':'4').lc($b->{'nick'}))} $channel->nicks()) {
            my $realnick = $nick->{'nick'};
            my $gone = $nick->{'gone'};
            
            my $prefix;
            if ($nick->{'op'}) { $prefix="@"; $ops++; }
            elsif ($nick->{'halfop'}) { $prefix="%"; $halfops++; }
            elsif ($nick->{'voice'}) { $prefix="+"; $voices++; }
            else { $prefix=" "; $normal++; }
            
            $prefix="%W$prefix%n";
            if ($gone) { $realnick="%K$realnick%n"; $away++; }
            
            push @nicks,"$prefix".$realnick;
        }
        my $total=@nicks;
        $channel->print("%K[%n%gUsers%n %G".$chan."%n%K]%n",MSGLEVEL_CLIENTCRAP);
        columnize_nicks($channel,@nicks);
        $channel->print("%W$chan%n: Total of %W$total%n nicks %K[%W$ops%n ops, %W$halfops%n halfops, %W$voices%n voices, %W$normal%n normal, %W$away%n away%K]%n",MSGLEVEL_CLIENTNOTICE);
    }
}

# create a /names style column, increasing alphabetically going down the 
# columns.
sub columnize_nicks {
    my ($channel,@nicks) = @_;
    my $total=@nicks;
    # determine max columns
    my $cols=Irssi::settings_get_int("names_max_columns");
    if ($cols == 0) { $cols = 6; }
    # determine number of rows
    my $rows=round(ceil($total/$cols));

    # array of rows
    my @r;
    for(my $i=0;$i<$cols;$i++) {
        # peek at next $rows items, determine max length
        my $max_length=find_max_length(@nicks[0..$rows-1]);

        # fill rows
        for(my $j=0;$j<$rows;$j++) {
            my $n=shift @nicks; # single nick
            if ($n ne "") {
                $r[$j] .= "%K[%n$n".fill_spaces($n,$max_length)."%K]%n ";
            }
        }
        
        # alternate method? broken.
        #@r[0..$rows-1] = map { $r[ $_ ] . ($r[$_] eq "" ? "" : "%K[%n$_" . fill_spaces( $nicks[ $_ ], $max_length ) . "%K]%n ") } (0 .. ($rows-1));
        #splice @nicks, 0, $rows;
    }
    for(my $m=0;$m<$rows;$m++) {
        chomp $r[$m];
        $channel->print($r[$m],MSGLEVEL_CLIENTCRAP);
    }
}

sub fill_spaces {
    my ($text,$max_length)=@_;
    $text =~ s/%[a-zA-Z]//g;
    return " " x ($max_length-length($text));
}

sub find_max_length {
    my $max_length=0;
    for (my $i=0;$i<@_;$i++) {
        my $nick = $_[$i];
        $nick =~ s/%[a-zA-Z]//g;
        if (length($nick) > $max_length) {
            $max_length=length($nick);
        }
    }
    return $max_length;
}

sub round {
    my($number)=@_;
    return int($number + .5);
}

#sub do_all_who {
#    #print "Doing all who..";
#    my @servers = Irssi::servers();
#    #Irssi::print Dumper \@servers,MSGLEVEL_CLIENTCRAP;
#    
#    foreach my $server (@servers) {
#        my $name=$server->{'chatnet'};
#        foreach my $channel ($server->channels()) {
#            my $channame=$channel->{'name'};
#            $server->redirect_event("who",1,$channame,0,undef, {
#                "event 352" => "redir who_reply",
#                "event 315" => "redir who_reply_end",
#            });
#            $server->command("who $channame");           
#        }
#    }
#}

sub who_reply {
    my($server,$data)=@_;
    my(undef,$c,$i,$h,$n,$s)=split / /,$data;
    if ($tmp_chan ne $c) {
        $tmp_chan=$c;
        #print "Got who info for $c";
    }
}

sub who_reply_end {
    $tmp_chan="";
}

#Irssi::Irc::Server::redirect_register("who",0,0,
#    {"event 352" => 1},
#    {"event 315" => 1},
#    undef
#);

#Irssi::signal_add("redir who_reply",\&who_reply);
#Irssi::signal_add("redir who_reply_end",\&who_reply_end);

Irssi::command_bind("anames",\&cmd_anames);
#Irssi::command_bind("dowho",\&do_all_who);

#Irssi::timeout_add($who_timer*1000,"do_all_who","");
