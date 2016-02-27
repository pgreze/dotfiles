# This script is a drop-in HTML filter and parser for use with bitlbee and
# irssi. HTML that can be rendered will be, and the rest will be stripped.
# This should not interfere with other scripts for bitlbee; it is intended to be
# a transparent mangler.
#
# I have worked out many, many bugs trying to get this script working as it
# should. If you notice something out of the ordinary, please contact me
# (http://f0rked.com/contact) and report the problem so I can fix it.
#
# TO USE:
# 1) Adjust the channel and server tag settings below.
# 2) Load the script
# 3) In the bitlbee control channel (&bitlbee), type: set strip_html false
# 4) Enjoy.
#
# For use with bitlbee 1.0+. ChangeLog is available at the bottom of the file.
#
# SETTINGS
# [bitlbee]
# bitlbee_replace_html = ON
#   -> replaces HTML in incoming AIM messages
# bitlbee_replace_control_codes = OFF
#   -> replaces control codes (bold, underline, reverse) in outgoing private 
#      messages to AIM users with HTML equivalents. This is turned off by
#      default due to the known bug below. If this wouldn't bother you, and you
#      would like to have this feature, there's no real harm in turning it on.
# bitlbee_strip_trailing_whitespace = OFF
#   -> removes whitespace at the end of messages
#
# KNOWN BUGS
# * This script is somewhat incompatible with splitlong.pl. When long messages
#   get split up, and bitlbee_replace_control_codes is ON, the control codes
#   will properly get replaced when they are sent to the remote user, but when
#   the subsequent split parts are displayed, they may contain the html that
#   is supposed to be hidden.
use strict;
use Irssi::TextUI;
use Data::Dumper;

use vars qw($VERSION %IRSSI);

$VERSION = '0.93';
%IRSSI = (
    authors     => 'Matt "f0rked" Sparks',
    contact     => 'root@f0rked.com',
    name        => 'bitlbee_html',
    description => 'Adds some HTML parsing to bitlbee messages',
    license     => 'GPLv2',
    url         => 'http://f0rked.com',
    changed     => '2005-12-05',
);

# TODO: Make these settings (?)
my $bitlbee_channel="&bitlbee";
my $bitlbee_server_tag="IM";

# Time to wait to collect all parts of a message from bitlbee server
my $buffer_timeout=200; # milliseconds

my %buffer;
my %emitting;
my $debug=0;

# Thanks to timing (http://the-timing.nl) for this
Irssi::signal_add_last 'channel sync' => sub {
    my($channel)=@_;
    if ($channel->{topic} eq "Welcome to the control channel. Type \x02help\x02 for help information.") {
        $bitlbee_server_tag=$channel->{server}->{tag};
        $bitlbee_channel=$channel->{name};
    }
};

sub trim {
    ($_)=@_;
    s/^\s*(.+)\s*$/$1/;
    return $_;
}

# return true if given address supports HTML, false if not.
sub does_html {
    my($address)=@_;
    return ($address =~ /^[a-z].*\@login\.oscar\.aol\.com$/i
            || $address =~ /^[a-z].*\@login\.icq\.com$/i) ? 1 : 0;
}

sub handle_link {
    my($url,$title)=@_;
    if ($url eq $title) { return $url; }
    elsif ($url eq "mailto:$title") { return $title; }
    else {
        my $str="[$title]($url)";
        $str=~s/^\[(\n)*/$1\[/;
        return $str;
    }
}    

sub html2irc {
    ($_)=@_;
    #print "Before: $_";
    s/<br ?\/?>/\n/ig;
    s/<font .+?>//ig;
    s/<\/font>//ig;
    s/<\/?body.*?>//ig;
    s/<\/?html>//ig;
    s/<a href="(.+?)">(.*?)<\/a>/handle_link($1,$2)/iesg;
    # note for <b>,<i>, and <u>, these are encapsulating tags, and they _may_
    # contain newlines. This script will split by newlines and emit message
    # signals for each part, and a part may end up looking like "<b>foo" with
    # no end tag, because the end tag is on the next message. To fix this, we
    # have to also check for <b>foo\n and ^foo</b> and put the control codes
    # in the appropriate places to avoid formatting the wrong text.
    s/<b>(.*?)<\/b>/\002$1\002/ig; # bold
    s/<b>(.*?)\n/\002$1\n/img;
    s/^(.*?)<\/b>/\002$1\002/img;
    
    s/<u>(.*?)<\/u>/\037$1\037/ig; # underline
    s/<u>(.*?)\n/\037$1\n/img;
    s/^(.*?)<\/u>/\037$1\037/img;
    
    s/<i>(.*?)<\/i>/\026$1\026/ig; # reverse (for italics)
    s/<i>(.*?)\n/\026$1\n/img;
    s/^(.*?)<\/i>/\026$1\026/img;
    s/&quot;/"/ig;
    s/&lt;/</ig;
    s/&gt;/>/ig;
    s/&amp;/&/ig;
    #print "After: $_";
    return $_;
}

sub irc2html {
    ($_)=@_;
    if (/^<html>/) {
        # Already htmlized? This shouldn't happen. Assume that html tags were
        # manually inserted, in which case we should just escape the html and 
        # return.
        s/&/&amp;/g;
        s/"/&quot;/g;
        s/</&lt;/g;
        s/>/&gt;/g;
        return "<html>$_</html>";
    }
    #print "Before: $_, length: ".length($_);
    my $orig=$_;
    
    s/&/&amp;/g;
    s/"/&quot;/g;
    s/</&lt;/g;
    s/>/&gt;/g;
    
    s/\002(.*?)\002/<b>$1<\/b>/g; # bold
    s/\002(.*)/<b>$1<\/b>/g;      # unended bold
    s/\037(.*?)\037/<u>$1<\/u>/g; # underline
    s/\037(.*)/<u>$1<\/u>/g;
    s/\026(.*?)\026/<i>$1<\/i>/g; # reverse (italics)
    s/\026(.*)/<i>$1<\/i>/g;
    s/\003/<br>/g;                # newlines.. this is ctrl+c in irssi.
    #print "After: $_, length: ".length($_);
    return ($_ ne $orig) ? "<html>$_</html>" : $orig;
}

sub event_privmsg {
    my($server,$msg,$nick,$address)=@_;
    return if !Irssi::settings_get_bool("bitlbee_replace_html");
    return if !does_html($address);
    return if $emitting{"priv_$nick"}; # don't catch if we're sending signal
    if ($server->{tag} eq $bitlbee_server_tag) {
        #print "Received msg: $msg";
        # Check the buffer. If it is empty, set a timeout. Fill it in either
        # case. This step is necessary because long messages will naturally
        # get split up, and to avoid the HTML cutting split up, we buffer
        # and then parse everything at once.
        if (!$buffer{"priv_$nick"}) {
            # We have no buffer, this is a new message
            my @data=("priv",$server,$nick,$address);
            Irssi::timeout_add_once($buffer_timeout,"check_buffer",\@data);
        }
        $msg.=" ";
        print "Adding part: '$msg'" if $debug;
        $buffer{"priv_$nick"}.=$msg;#."\002|\002";
        # Length hack. Sometimes we get multiple messages quickly from bitlbee
        # that aren't html formatted with <br>. Detect this and add newlines
        # appropriately.
        my $length=length("$nick $address $msg");
        print "Length: $length" if $debug;
        if ($length<450) {
            $buffer{"priv_$nick"}.="\n";
        }
        Irssi::signal_stop;
    }
}

sub event_pubmsg {
    my($server,$msg,$nick,$address,$target)=@_;
    return if !Irssi::settings_get_bool("bitlbee_replace_html");
    return if !does_html($address) and $nick ne "root"; # only aim does html.
    return if $emitting{"pub_$nick"};
    if ($server->{tag} eq $bitlbee_server_tag) {
        if (!$buffer{"pub_$nick"}) {
            my @data=("pub",$server,$nick,$address,$target);
            Irssi::timeout_add_once($buffer_timeout,"check_buffer",\@data);
        }
        $buffer{"pub_$nick"}.=$msg;
        if (length("$nick $address $msg $target")<450) {
            $buffer{"pub_$nick"}.="\n";
        }
        Irssi::signal_stop;
    }
}

sub event_action {
    my($server,$msg,$nick,$address,$target)=@_;
    #print $msg;
    return if !Irssi::settings_get_bool("bitlbee_replace_html");
    return if !does_html($address);
    return if $emitting{"act_$nick"};
    if ($server->{tag} eq $bitlbee_server_tag) {
        if (!$buffer{"act_$nick"}) {
            my @data=("act",$server,$nick,$address,$target);
            Irssi::timeout_add_once($buffer_timeout,"check_buffer",\@data);
        }
        $buffer{"act_$nick"}.=$msg;
        if (length("$nick $address $msg $target")<450) {
            $buffer{"act_$nick"}.="\n";
        }
        Irssi::signal_stop;
    }
}

sub event_send_text {
    my($text,$server,$witem)=@_;
    return if $server->{tag} ne $bitlbee_server_tag;
    return if !Irssi::settings_get_bool("bitlbee_replace_control_codes");
    # This will make sure that the person we are talking to is on AIM.
    my $address;
    my $modified_text=$text;
    if ($witem->{type} eq "CHANNEL") {
        if (my($n,$s,$m) = $text =~ /^([^ ]+):([ ]*)(.*)$/) {
            $address=$witem->nick_find($n)->{host};
            $modified_text="$n:$s".irc2html($m);
        }
    }
    else {
        $address=$witem->{address};
        $modified_text=irc2html($text);
    }
    return if !does_html($address);
    #print Dumper $witem;
    #print "Sending: $modified_text";
    Irssi::signal_stop;
    Irssi::signal_continue($modified_text,$server,$witem);
}

sub event_message_own {
    my($server,$msg,$target,$orig_target)=@_;
    return if $server->{tag} ne $bitlbee_server_tag;
    return if !Irssi::settings_get_bool("bitlbee_replace_control_codes");
    return if !Irssi::settings_get_bool("bitlbee_replace_html");
    if ($msg =~ /^<html>/ || $msg =~ /^([^ ]+):[ ]*<html>/) {
        # If we're on the bitlbee server and the message looks like html, 
        # we're here.
        #print "$server '$msg' $target $orig_target";        
        
        if ($orig_target && (my $qu=$server->query_find($target))) {
            #print "orig target, found query.";
            if ($qu->{address} && !does_html($qu->{address})) {
                # The person we're talking to is not using an HTML-compatible
                # protocol. Don't treat this as html.
                return;
            }
        }
        elsif (!$orig_target && 
               (my $ch=$server->channel_find($target)) &&
               (my($t)=$msg=~/^([^ ]+):/)) 
        {
            my $to_nick=$ch->nick_find($t);
            if ($to_nick->{address} && !does_html($to_nick->{address})) {
                # We're talking to someone in a particular channel on 
                # bitlbee, but they don't support HTML.
                return;
            }
        }
        # If we made it this far, treat the message as HTML.
        Irssi::signal_stop;
        Irssi::signal_continue($server,html2irc($msg),$target,$orig_target);
    }    
}

sub check_buffer {
    my($type,$server,$nick,$address,$target)=@{@_[0]};
    # We should now have a full buffer for $nick, we can examine it, parse
    # it, and re-emit the appropriate signals without any HTML splitting
    # problems.
    my $msg=$buffer{"${type}_${nick}"};
    print "Complete msg: $msg" if $debug;
    return if !$msg;
    $msg=html2irc($msg);
    $msg=~s/[\s]*$//
            if Irssi::settings_get_bool("bitlbee_strip_trailing_whitespace");
    # $msg is now in the appropriate format, we can emit the signal.
    $emitting{"${type}_${nick}"}=1;
    my $sig="message ";
    if ($type eq "priv") {   $sig.="private";    }
    elsif ($type eq "pub") { $sig.="public";     }
    else {                   $sig.="irc action"; }
    #print "Emitting $sig";
    for(split /\n/,$msg) {
        Irssi::signal_emit($sig,$server,$_,$nick,$address,$target);
    }
    delete($buffer{"${type}_${nick}"});
    delete($emitting{"${type}_${nick}"});
}

sub event_301 {
    return if !Irssi::settings_get_bool("bitlbee_replace_html");    
    my($server,$data,$foo,$bar)=@_;
    if ($server->{tag} eq $bitlbee_server_tag) {
        my($me,$them,@msg)=split / /,$data;
        my $msg=join ' ',@msg;
        $msg=html2irc($msg);
        $msg=~s/[\s]*$// 
            if Irssi::settings_get_bool("bitlbee_strip_trailing_whitespace");
        Irssi::signal_stop;
        Irssi::signal_continue($server,"$me $them $msg",$foo,$bar);
    }
}

sub foo {
    for(@_){print;}
}

Irssi::signal_add_first("message private","event_privmsg");
Irssi::signal_add_first("message public","event_pubmsg");
Irssi::signal_add_first("event 301","event_301");
Irssi::signal_add_first("message irc action","event_action");

Irssi::signal_add_first("send text","event_send_text");
Irssi::signal_add_first("message own_private","event_message_own");
Irssi::signal_add_first("message own_public","event_message_own");
Irssi::signal_add_first("message irc own_action","event_message_own");

# Settings
Irssi::settings_add_bool("bitlbee","bitlbee_replace_html",1);
Irssi::settings_add_bool("bitlbee","bitlbee_replace_control_codes",0);
Irssi::settings_add_bool("bitlbee","bitlbee_strip_trailing_whitespace",0);

### ChangeLog ###
# Version 0.93
#   - fixed a stupid case issue in address recognization.
# Version 0.92
#   - code cleanups
#   - control codes are allowed in control channel, but targets must be used
#     (remoteuser: I'm talking to you) (this is the default)
# Version 0.91
#   - more intelligent checking for HTML support
#   - allowed html from AIM users over ICQ connections
# Version 0.9
#   - removed html parsing for non-AIM connections
#   - added support for replacing control codes (created by ctrl+b, ctrl+v, and
#     cltr+-) with html equivalents. Disabled by default.
#
# Version 0.8 (2005-12-02)
#   - Initial public release

