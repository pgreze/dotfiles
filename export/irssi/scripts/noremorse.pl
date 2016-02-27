#!/usr/bin/perl
#
# script qui kick les vilains qui écrivent pas en morse sur les channels indiqués
#
# paramètres:
#  morse_channels       str     liste des chans à protéger

use Irssi;
use Irssi::Irc;
use vars %IRSSI;

%IRSSI =
(
        authors         => "Warnaud",
        contact         => "warnaud\@gmail.com",
        name            => "noremorse",
        description     => "degomme les nains qui ecrivent pas en morse",
        license         => "c'est la fête",
        written         => "Aujourd'hui",
        changed         => "Demain"
);

my @reasons = (". -.   -- --- .-. ... .   -- . .-. -.-. ..",
". -.   -- --- .-. ... . --..--   --- -.   .-   -.. .. -",
".-. . .-.. .. ...   .-.. .   - --- .--. .. -.-. --..--   ..-. .- ..- -   . -.-. .-. .. .-. .   . -.   -- --- .-. ... .",
".-. . - --- ..- .-. -. .   .- .--. .--. .-. . -. -.. .-. .   .-.. .   -- --- .-. ... .");

sub catch_junk
{
        my ($server, $data, $nick, $address) = @_;
        my ($target, $text) = split(/ :/, $data, 2);
        my $valid = 0;
        if ($target[0] != '#' && $target[0] != '!' && $target[0] != '&')
        {
                return;
        }

        for my $channel (split(/ /,
                Irssi::settings_get_str('morse_channels')))
        {
                if($target eq $channel)
                {
                        $valid = 1;
                        last;
                }
        }
        if (($valid == 1) && !($text =~ /^[- .]*$/ ))
        {
                $server->send_raw("KICK $target $nick :".$reasons[int(rand(@reasons))]);
        }
}

Irssi::settings_add_str('noremorse', 'morse_channels', '#morsefr');
Irssi::signal_add("event privmsg", "catch_junk");
