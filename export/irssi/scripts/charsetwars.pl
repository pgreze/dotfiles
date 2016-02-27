# Comments/bugs/improvements/suggestions welcome.
#
# Look also at <http://norpan.org/charconv.c> (listed on <http://www.irssi.org/?page=plugins>).
#
# Requires Text::Iconv (libtext-iconv-perl on Debian).
#
# Usage:
#   /charsetwars_help

# TODO:
# - numerate lists, and allow references to the indexes
# - separate enemies list for guesses and user entered (?)
# - use Perl's Encode ($ man 3perl Encode) (?)
#
# CHANGES:
# * 2004-02-10:
#   - 0.69.1
#   - removed hardcoded iso8859-1 accented characters from %guesses initialization (they got messed up by the editor using utf-8)
#
# * 2004-02-09 (later):
#   - 0.69.0
#   - external guess list (charsetwars.guess)
#   - user command for adding guesses (/charsetwars_guess_add)
#
# * 2004-02-09:
#   - 0.68.0
#   - added guess_wrong_charset() (detect wrong setting of enemy charset)
#   - started this "changelog"



use strict;
use vars qw($VERSION %IRSSI);

use Irssi;

use Text::Iconv;
use Data::Dumper;


$VERSION = '0.69.1';
%IRSSI = (
    authors	=> 'Gustavo De Nardin ("spuk"), with ideas from recode.pl (...), irssiq.pl (Data::Dumper), charconv.c (ircnet/channel/nick associations), others ...',
    contact	=> 'spuk@ig.com.br',
    name	=> 'charsetwars',
    description	=> 'Converts messages between charsets (utf-8 <=> iso8859-1, etc.) by nick/channel/ircnet. With "dumb" (regexp) guessing for any charset (user configured).',
    license	=> 'Public Domain',
    url		=> 'http://www.inf.ufsc.br/~nardin/irssi/',
    changed	=> '2004-02-09',
);


# Enable saving with Irssi settings
Irssi::settings_add_bool("charsetwars.pl", "charsetwars_autosave", 1);
# Enable or disable charsetwars conversion from incoming messages
Irssi::settings_add_bool("charsetwars.pl", "charsetwars_convert_in", 1);
# Enable or disable charsetwars conversion to outgoing messages
Irssi::settings_add_bool("charsetwars.pl", "charsetwars_convert_out", 0);
# Default is to not touch the messages
Irssi::settings_add_str("charsetwars.pl", "charsetwars_default_in", "AS_IS");
Irssi::settings_add_str("charsetwars.pl", "charsetwars_default_out", "AS_IS");
# The charset you're using
Irssi::settings_add_str("charsetwars.pl", "charsetwars_own", "iso8859-1");
# Guessing of incoming message charset
Irssi::settings_add_bool("charsetwars.pl", "charsetwars_guess_in", 1);
# Guessing of wrong charset in messages
Irssi::settings_add_bool("charsetwars.pl", "charsetwars_wrong_guess", 1);
# Persistent guesses
Irssi::settings_add_bool("charsetwars.pl", "charsetwars_guess_ln", 1);
# Remove wrong guesses (a conversion for which an error has ocurred)
Irssi::settings_add_bool("charsetwars.pl", "charsetwars_rm_on_err", 1);


Irssi::theme_register([
'charsetwars_list_head', '%_---%_ Enemy => Crime %_---%_',
'charsetwars_list_body', '%_$0%_@%_$1%_ => $2',
'charsetwars_list_foot', '%_---%_ Enemies finished %_---%_',
'charsetwars_rm', 'Peace treaty with %_$0%_@%_$1%_.',
'charsetwars_ln', 'Declared %_$0%_@%_$1%_ an enemy for crime of %_$2%_.',
'charsetwars_guess', 'Detected %_$0%_@%_$1%_ firing %_$2%_.',
'charsetwars_guesses_head', '%_---%_ Guesses on $0 %_---%_',
'charsetwars_guesses_body', '%_$1%_ matching /$2/',
'charsetwars_guesses_foot', '%_---%_ End of guesses on $0 %_---%_',
'charsetwars_guesses_add', 'Added guess for %_$1%_ on $0 matching /$2/.',
'charsetwars_guesses_del', 'Removed guess for %_$1%_ on $0.',
]);


# Regular expressions for guessing of charsets
our %guesses = ();
# own_charset => in_charset = "RE"
# ("out-of-the-box" detected charsets)
$guesses{'iso8859-1'}{'utf-8'} = "á|é|í|ó|ú|ã|ç|à|ô|ê";
$guesses{'utf-8'}{'iso8859-1'} = Text::Iconv->new('utf-8', 'iso8859-1')->convert($guesses{'iso8859-1'}{'utf-8'});


# hash of hashes: $enemies{$ircnet}{$nickchan} = $charset
our %enemies;


# "cache" converters
our %iconv_cache_in = ();
our %iconv_cache_out = ();


# Keep track of change
our $own_charset = Irssi::settings_get_str('charsetwars_own');


# filename for saving list of enemies
our $valhalla = "charsetwars.list";

# filename for saving list of guesses
our $guessfile = "charsetwars.guess";



sub cmd_charsetwars_help {
    my $help = "
[charsetwars.pl]
Usage:
  /charsetwars_ln CHARSET NICK/CHANNEL [IRCNET]  - links NICK/CHANNEL to CHARSET [on IRCNET] *
  /charsetwars_rm NICK/CHANNEL [IRCNET]          - removes link specified [on IRCNET] **
  /charsetwars_ls                                - lists links
  /charsetwars_load                              - loads ".Irssi::get_irssi_dir()."/".$valhalla."
  /charsetwars_save                              - saves ".Irssi::get_irssi_dir()."/".$valhalla."
  /charsetwars_guess_show [THIS]                 - shows available guesses [for THIS charset] ***
  /charsetwars_guess_add CHARSET CHARS           - adds guess for incoming CHARSET using CHARS ****
  /charsetwars_guess_del CHARSET                 - dels guess for incoming CHARSET

     * any of NICK/CHANNEL IRCNET can be '*'
    ** IRCNET defaults to '*'
   *** THIS defaults to charsetwars_own
  **** CHARS is a regexp that should match characters you commonly see from people using CHARSET
       (i.e., like some non-ASCII characteres, each separated by |)

Settings (and default values):
  charsetwars_autobury (ON)        - auto-save links (when Irssi saves settings)
  charsetwars_own (iso8859-1)      - your charset (this can\'t be autodetected)
  charsetwars_convert_in (ON)      - convert incoming messages
  charsetwars_convert_out (OFF)    - convert outgoing messages
  charsetwars_guess_in (ON)        - try to guess charset of incoming messages
  charsetwars_wrong_guess (ON)     - try to detect wrong charset in messages (like one using UTF-8 but set as ISO8859-1)
  charsetwars_guess_ln (ON)        - do charsetwars_ln on guesses
  charsetwars_default_in (AS_IS)   - default \'in\' charset (AS_IS == no conversion)
  charsetwars_default_out (AS_IS)  - default \'out\' charset (AS_IS == no conversion)
  charsetwars_rm_on_err (ON)       - do charsetwars_rm on conversion error
";

    Irssi::print($help, MSGLEVEL_CLIENTCRAP);
}
Irssi::command_bind('charsetwars_help', 'cmd_charsetwars_help', 'charsetwars.pl');


sub cmd_guess_show {
    my ($this,) = split(/ +/, $_[0]);

    $this = Irssi::settings_get_str('charsetwars_own') if (!$this);

    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'charsetwars_guesses_head', $this);
    foreach my $charset (keys %{ $guesses{$this} }) {
        my $regexp = $guesses{$this}{$charset};
        Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'charsetwars_guesses_body', $this, $charset, $regexp);
    }
    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'charsetwars_guesses_foot', $this);
}
Irssi::command_bind('charsetwars_guess_show', 'cmd_guess_show', 'charsetwars.pl');


sub cmd_guess_add {
    my ($charset, $chars) = split(/ +/, $_[0]);
    my $own_charset = Irssi::settings_get_str('charsetwars_own');

    if (!$charset || !$chars) {
        Irssi::print('[charsetwars.pl] Missing arguments. See /charsetwars_help for usage.', MSGLEVEL_CLIENTCRAP);
        return;
    }

    $guesses{$charset}{$own_charset} = $chars;
    $guesses{$own_charset}{$charset} = Text::Iconv->new($own_charset, $charset)->convert($chars);
    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'charsetwars_guesses_add', $own_charset, $charset, $chars);
}
Irssi::command_bind('charsetwars_guess_add', 'cmd_guess_add', 'charsetwars.pl');


sub cmd_guess_del {
    my ($charset) = split(/ +/, $_[0]);
    my $own_charset = Irssi::settings_get_str('charsetwars_own');

    if (!$charset) {
        Irssi::print('[charsetwars.pl] Missing arguments. See /charsetwars_help for usage.', MSGLEVEL_CLIENTCRAP);
        return;
    }

    my $chars = $guesses{$own_charset}{$charset};
    delete($guesses{$own_charset}{$charset});
    delete($guesses{$charset});
    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'charsetwars_guesses_del', $own_charset, $charset, $chars);
}
Irssi::command_bind('charsetwars_guess_del', 'cmd_guess_del', 'charsetwars.pl');


# Adds a nick/channel -> charset link
sub cmd_charsetwars_ln {
    my ($charset, $nickchan, $ircnet) = split(/ +/, $_[0]);

    if (!$charset || !$nickchan) {
        Irssi::print('[charsetwars.pl] Missing arguments. See /charsetwars_help for usage.', MSGLEVEL_CLIENTCRAP);
        return;
    }

    $ircnet = '*' if (!$ircnet);

    $enemies{$ircnet} = () if (!$enemies{$ircnet});
    $enemies{$ircnet}{$nickchan} = $charset;
    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'charsetwars_ln', $nickchan, $ircnet, $enemies{$ircnet}{$nickchan});
}
Irssi::command_bind('charsetwars_ln', 'cmd_charsetwars_ln', 'charsetwars.pl');


# Removes nick -> charset links
sub cmd_charsetwars_rm {
    my ($nickchan, $ircnet) = split(/ +/, $_[0]);

    if (!$nickchan) {
        Irssi::print('[charsetwars.pl] Missing arguments. See /charsetwars_help for usage.', MSGLEVEL_CLIENTCRAP);
        return;
    }

    $ircnet = '*' if (!$ircnet);

    if ($ircnet =~ '\*') {
        foreach my $ircnet (keys %enemies) {
            if (delete($enemies{$ircnet}{$nickchan})) {
                Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'charsetwars_rm', $nickchan, $ircnet);
            }
        }
    }
    else {
        if (delete($enemies{$ircnet}{$nickchan})) {
            Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'charsetwars_rm', $nickchan, $ircnet);
        }
    }
}
Irssi::command_bind('charsetwars_rm', 'cmd_charsetwars_rm', 'charsetwars.pl');


# Lists nick -> charset links
sub cmd_charsetwars_ls {
    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'charsetwars_list_head');
    foreach my $ircnet (sort(keys %enemies)) {
        foreach my $enemy (sort(keys %{ $enemies{$ircnet} })) {
            my $crime = $enemies{$ircnet}{$enemy};
            Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'charsetwars_list_body', $enemy, $ircnet, $crime);
        }
    }
    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'charsetwars_list_foot');
}
Irssi::command_bind('charsetwars_ls', 'cmd_charsetwars_ls', 'charsetwars.pl');


# Saves %enemies
sub bury_enemies {
    my $cfgdir = Irssi::get_irssi_dir();
    my $cfgdumper = Data::Dumper->new([\%enemies], ['*enemies']);
    open(CFG, ">", $cfgdir."/".$valhalla);
    print CFG $cfgdumper->Dump;
    close(CFG);
    Irssi::print('Enemies buried.');
}
sub auto_save {
    bury_enemies() if (Irssi::settings_get_bool('charsetwars_autosave'));
    save_guesses() if (Irssi::settings_get_bool('charsetwars_autosave'));
}
Irssi::signal_add('setup saved', 'auto_save');
Irssi::command_bind('charsetwars_save', 'bury_enemies', 'charsetwars.pl');


# Loads %enemies
sub revive_enemies {
    my $cfgdir = Irssi::get_irssi_dir();
    my $cfg;
    open(CFG, "<", $cfgdir."/".$valhalla);
    while (<CFG>) { $cfg .= $_; }
    eval $cfg;
    close(CFG);
    Irssi::print('Enemies revived.');
}
Irssi::signal_add('setup reread', 'revive_enemies');
Irssi::command_bind('charsetwars_load', 'revive_enemies', 'charsetwars.pl');
revive_enemies();


# Saves %guesses
sub save_guesses {
    my $cfgdir = Irssi::get_irssi_dir();
    my $cfgdumper = Data::Dumper->new([\%guesses], ['*guesses']);
    open(CFG, ">", $cfgdir."/".$guessfile);
    print CFG $cfgdumper->Dump;
    close(CFG);
    Irssi::print('Guesses saved.');
}
Irssi::command_bind('charsetwars_guess_save', 'save_guesses', 'charsetwars.pl');


# Loads %guesses
sub load_guesses {
    my $cfgdir = Irssi::get_irssi_dir();
    my $cfg;
    open(CFG, "<", $cfgdir."/".$guessfile);
    while (<CFG>) { $cfg .= $_; }
    eval $cfg;
    close(CFG);
    Irssi::print('Guesses loaded.');
}
Irssi::signal_add('setup reread', 'load_guesses');
Irssi::command_bind('charsetwars_guess_load', 'load_guesses', 'charsetwars.pl');
load_guesses();




# Invalidate iconv_cache_{in,out}
sub invalidate_iconv_caches {
    %iconv_cache_in = ();
    %iconv_cache_out = ();
    $own_charset = Irssi::settings_get_str('charsetwars_own');
}


sub guess_charset {
    my ($txt) = @_;

    foreach my $charset (keys %{ $guesses{$own_charset} }) {
        if ($txt =~ /$guesses{$own_charset}{$charset}/) {
            return $charset;
        }
    }
    return undef;
}


sub guess_wrong_charset {
    my ($in_charset, $txt) = @_;

    foreach my $charset (keys %{ $guesses{$in_charset} }) {
        if ($txt =~ /$guesses{$in_charset}{$charset}/) {
            return $charset;
        }
    }
    return undef;
}


sub get_charset {
    my ($txt, $nick, $ircnet, $channel) = @_;
    my $charset;

    $charset = $enemies{$ircnet}{$nick};
    if (!$charset) {
        $charset = $enemies{'*'}{$nick};
    }
    if (!$charset) {
        $charset = $enemies{$ircnet}{$channel};
    }
    if (!$charset) {
        $charset = $enemies{'*'}{$channel};
    }
    if (!$charset) {
        $charset = $enemies{$ircnet}{'*'};
    }
    if (!$charset && Irssi::settings_get_bool('charsetwars_guess_in')) {
        $charset = guess_charset($txt);
        Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'charsetwars_guess', $nick, $ircnet, $charset) if ($charset);
        if ($charset && Irssi::settings_get_bool('charsetwars_guess_ln')) {
            cmd_charsetwars_ln($charset." ".$nick." ".$ircnet);
        }
    }
    if (!$charset) {
        $charset = Irssi::settings_get_str('charsetwars_default_in');
    }

    return $charset;
}


sub convert_txt {
    my ($in_out, $charset, $txt, $nick, $channel, $ircnet) = @_;
    my %cache;

    if (!$txt) { return $txt; }

    if ($in_out == 'in') {
        %cache = %iconv_cache_in;
    }
    elsif ($in_out == 'out') {
        %cache = %iconv_cache_out;
    }

    my $iconv = $cache{$charset};
    if (!$iconv) {
        if ($in_out =~ 'in') {
            $iconv = Text::Iconv->new($charset, $own_charset);
        }
        elsif ($in_out =~ 'out') {
            $iconv = Text::Iconv->new($own_charset, $charset);
        }
        $iconv->raise_error(0);
        $cache{$charset} = $iconv;
    }

    my $txt_ret = $iconv->convert($txt);

    if (!$txt_ret
        or (Irssi::settings_get_bool('charsetwars_wrong_guess') && guess_wrong_charset($charset, $txt))) {
        Irssi::print("[charsetwars.pl:convert_txt()] Conversion error ($in_out, $charset, $txt, $nick, $channel, $ircnet)");
        if (Irssi::settings_get_bool('charsetwars_rm_on_err')) {
            if ($enemies{$ircnet}{$nick}) {
                cmd_charsetwars_rm($nick,$ircnet);
            } elsif ($enemies{$ircnet}{$channel}) {
                cmd_charsetwars_rm($channel,$ircnet);
            } elsif ($enemies{'*'}{$nick}) {
                cmd_charsetwars_rm($nick,'*');
            } elsif ($enemies{'*'}{$channel}) {
                cmd_charsetwars_rm($channel,'*');
            }
        }
        return $txt;
    } else {
        return $txt_ret;
    }
}


# Returns $txt converted from the charset
sub convert_in {
    my ($txt, $nick, $ircnet, $channel) = @_;

    # own messages not converted
#    if ($nick =~ Irssi::active_server()->{nick}) {
#        return $txt;
#    }

    my $in_charset = get_charset($txt, $nick, $ircnet, $channel);

    if ($in_charset =~ 'AS_IS' || $in_charset =~ $own_charset || !Irssi::settings_get_bool('charsetwars_convert_in')) {
        return $txt;
    }

    # user changed 'charsetwars_own', invalidate caches
    if ($own_charset !~ Irssi::settings_get_str('charsetwars_own')) { invalidate_iconv_caches(); }

    return convert_txt('in', $in_charset, $txt, $nick, $channel, $ircnet);
}


# Returns $txt converted to the charset
sub convert_out {
    my ($txt, $nick, $ircnet, $channel) = @_;

    my $out_charset = get_charset($txt, $nick, $ircnet, $channel);

    if (!Irssi::settings_get_bool('charsetwars_convert_out') || $out_charset =~ 'AS_IS' || $out_charset =~ $own_charset) {
        return $txt;
    }

    # user changed 'charsetwars_own', invalidate caches
    if ($own_charset != Irssi::settings_get_str('charsetwars_own')) { invalidate_iconv_caches(); }

    return convert_txt('out', $out_charset, $txt, $nick, $channel, $ircnet);
}


# Signal wiring

sub send_text {
    my ($txt, $server, $witem) = @_;

    if ($witem) {
        $txt = convert_out($txt, $witem->{'name'}, $server->{'chatnet'}, $witem->{'name'});
    }
    Irssi::signal_continue($txt, $server, $witem);
}
Irssi::signal_add('send text', 'send_text');

sub message_public {
    my ($server, $msg, $nick, $addr, $target) = @_;

    $msg = convert_in($msg, $nick, $server->{'chatnet'}, $target);
    Irssi::signal_continue($server, $msg, $nick, $addr, $target);
}
Irssi::signal_add('message public', 'message_public');

sub message_own_public {
    my ($server, $msg, $target) = @_;

    $msg = convert_in($msg, $target, $server->{'chatnet'});
    Irssi::signal_continue($server, $msg, $target);
}
Irssi::signal_add('message own_public', 'message_own_public');

sub message_irc_action {
    my ($server, $msg, $nick, $addr, $target) = @_;

    $msg = convert_in($msg, $nick, $server->{'chatnet'}, $target);
    Irssi::signal_continue($server, $msg, $nick, $addr, $target);
}
Irssi::signal_add('message irc action', 'message_irc_action');

sub message_private {
    my ($server, $msg, $nick, $addr) = @_;

    $msg = convert_in($msg, $nick, $server->{'chatnet'});
    Irssi::signal_continue($server, $msg, $nick, $addr);
}
Irssi::signal_add('message private', 'message_private');

sub message_own_private {
    my ($server, $msg, $target, $orig_target) = @_;

    $msg = convert_in($msg, $target, $server->{'chatnet'});
    Irssi::signal_continue($server, $msg, $target, $orig_target);
}
Irssi::signal_add('message own_private', 'message_own_private');

sub message_notice {
    my ($server, $msg, $nick, $addr, $target) = @_;

    $msg = convert_in($msg, $nick, $server->{'chatnet'});
    Irssi::signal_continue($server, $msg, $nick, $addr, $target);
}
Irssi::signal_add('message irc notice', 'message_notice');

sub message_own_notice {
    my ($server, $msg, $target) = @_;

    $msg = convert_in($msg, $target, $server->{'chatnet'});
    Irssi::signal_continue($server, $msg, $target);
}
Irssi::signal_add('message irc own_notice', 'message_own_notice');

sub message_part {
    my ($server, $chan, $nick, $addr, $reason) = @_;

    $reason = convert_in($reason, $nick, $server->{'chatnet'}, $chan);
    Irssi::signal_continue($server, $chan, $nick, $addr, $reason);
}
Irssi::signal_add('message part', 'message_part');

sub message_quit {
    my ($server, $nick, $addr, $reason) = @_;

    $reason = convert_in($reason, $nick, $server->{'chatnet'});
    Irssi::signal_continue($server, $nick, $addr, $reason);
}
Irssi::signal_add('message quit', 'message_quit');

sub message_kick {
    my ($server, $chan, $nick, $kicker, $addr, $reason) = @_;

    $reason = convert_in($reason, $kicker, $server->{'chatnet'}, $chan);
    Irssi::signal_continue($server, $chan, $nick, $kicker, $addr, $reason);
}
Irssi::signal_add('message kick', 'message_kick');

sub message_topic {
    my ($server, $chan, $topic, $nick, $addr) = @_;

    $topic = convert_in($topic, $nick, $server->{'chatnet'}, $chan);
    Irssi::signal_continue($server, $chan, $topic, $nick, $addr);
}
Irssi::signal_add('message topic', 'message_topic');

