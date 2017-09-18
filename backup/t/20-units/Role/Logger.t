#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use FindBin;
use Test::More;
use Test::Log::Log4perl;

use lib "$FindBin::RealBin/../../lib";

use Metal;

my $m = Metal->new();
my $t = Test::Log::Log4perl->get_logger('Metal.Role.Logger');
my (@test_args, %test_hash);

# ->logf
$t->start();
$t->warn("Test 1 Test 2");
$m->logf("%s %s", [ "Test 1", "Test 2" ], "warn");
$t->end("`logf` produced warning output as expected");

$t->start();
$t->debug("Test 3 Test 4 - Test 5");
$m->logf("%s %s - %s", [ "Test 3", "Test 4", "Test 5" ], "debug");
$t->end("`logf` produced debug output as expected");

$t->start();
$t->info("Test 6");
$m->logf("%s", [ "Test 6" ]);
$t->end("`logf` produced info output as expected (no log level was set)");

# ->log_dump
@test_args = qw/foo bar/;
$t->start();
$t->info(Dumper(\@test_args));
$m->log_dump({ content => \@test_args });
$t->end("`log_dump` produced info output as expected (no log level was set)");

@test_args = qw/baz/;
$t->start();
$t->warn(Dumper(\@test_args));
$m->log_dump({ content => \@test_args, level => 'warn' });
$t->end("`log_dump` produced warn output as expected");

%test_hash = (foo => 'bar', asdf => 'ghjk');
$t->start();
$t->warn(Dumper(\%test_hash));
$m->log_dump({ content => \%test_hash, level => 'warn' });
$t->end("`log_dump` produced warn output (HashRef) as expected");

done_testing();
__END__

=head1 NAME

t/20-units/Role/Logger.t

=head1 DESCRIPTION

Test logger methods run as expected.

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

