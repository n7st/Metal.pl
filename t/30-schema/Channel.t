#!/usr/bin/env perl

use strict;
use warnings;

use DateTime;
use FindBin;
use Test::More;

use lib "$FindBin::RealBin/../../lib";

use Metal;

my $module = 'Metal::Schema';

use_ok($module);

my $metal = Metal->new();
my $now   = DateTime->now();

# TODO - for the next database test, move this to a module usable by other
# scripts
$module->connection('dbi:SQLite:dbname=:memory:', '', '')
    || BAIL_OUT("Failed to create a test database schema in memory");
$module->load_namespaces();
$module->deploy();

my $server = $module->resultset('Server')->new({
    hostname  => 'irc.test.com',
    id        => 1,
    port      => 6697,
    connect   => 0,
    join_chan => 0,
    debug     => 0,
    ssl       => 1,
    nickname  => 'TestBot',
    ident     => 'TestBot',

    date_created  => $now,
    date_modified => $now,
});

is($server->hostname, 'irc.test.com', "Server hostname looks OK");
is($server->id, 1, "Primary key is set");
is($server->date_created, $now, "DateField helper produced correct date_created");
is($server->date_modified, $now, "DateField helper produced correct date_modified");

my $channel = $module->resultset('Channel')->new({
    id        => 1,
    name      => '##SomeChannel',
    server_id => $server->id,

    date_created  => $now,
    date_modified => $now,
});

is($channel->server_id, $server->id, "Foreign key set, channel belongs to \$server");
is($channel->date_created, $now, "DateField helper produced correct date_created");
is($channel->date_modified, $now, "DateField helper produced correct date_modified");
like($channel->name, $metal->channel_regex, "Channel name is valid");

done_testing();

