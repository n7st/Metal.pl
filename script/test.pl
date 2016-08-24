#!/usr/bin/env perl
use strict;
use warnings;

use Data::Printer;

use lib 'lib';

use Metal;

my $metal = Metal->new({
    config => {
        server => {
            address => 'irc.snoonet.org',
            port    => 6667,
        },
    },
});

print $metal->input->test_input('bandinfo', {
    hostmask    => 'snoonet/operations/Netsplit',
    nick        => 'Mike',
    band        => 'Immolation',
    description => 'Test',
});

