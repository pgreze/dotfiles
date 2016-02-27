# (c) 2002 by Gerfried Fuchs <alfie@channel.debian.de>

use Irssi qw(signal_add_last settings_add_str settings_get_str signal_stop);
use strict;
use vars qw($VERSION %IRSSI);

$VERSION = '0.5.0';

%IRSSI = (
  'authors'     => 'Gerfried Fuchs',
  'contact'     => 'alfie@channel.debian.de',
  'name'        => 'thanks to fundraising',
  'description' => 'sends a thank you message back to fundraising notices',
  'license'     => 'GPLv2',
  'url'         => 'http://alfie.ist.org/projects/irssi/scripts/thankfund.pl',
  'changed'     => '2002-08-08',
);

# Maintainer & original Author:  Gerfried Fuchs <alfie@channel.debian.de>

# Version-History:
# ================
# 0.5.0 -- first try

# TODO List
# ... currently empty


sub sig_notice {
    my ($server, $msg, $nick, $address) = @_;
    $server->command("/^NOTICE $nick ".settings_get_str('thank_funding')) if
        ($msg =~ /^\[Global Notice\]/) and ($nick eq 'FUNDRAISING');
    signal_stop;
}

signal_add_last('message irc notice', 'sig_notice');
settings_add_str('misc', 'thank_funding', 'Thank you for the notice, it was quite interesting...');
