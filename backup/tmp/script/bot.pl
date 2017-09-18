#!/usr/bin/env perl

use strict;
use warnings;

use DDP;
use FindBin;
use POE qw/
    Component::IRC
    Session
/;

use lib "$FindBin::Bin/../lib";

use Metal;

################################################################################

my $metal = Metal->new();

my $session = POE::Session->create(inline_states => {
    _start => sub {
        my $bot = POE::Component::IRC->spawn();

        POE::Session->create(package_states => [
            $metal->input => [ qw/
                _start
                irc_001
                irc_notice
                irc_public
                irc_msg
            / ],
        ], heap => {
            irc => $bot,
        });
    },
});

################################################################################

POE::Kernel->run();
__END__

