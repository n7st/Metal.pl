#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use Test::More;
use Test::Log::Log4perl;

use lib "$FindBin::RealBin/../../lib";

use Metal;

my $m = Metal->new();
my $t = Test::Log::Log4perl->get_logger('Metal.Role.Logger');

$t->start();
$t->warn("Test 1 Test 2");
$m->logf("%s %s", [ "Test 1", "Test 2" ], "warn");
$t->end("`logf` produced warning output as expected");

$t->start();
$t->debug("Test 3 Test 4 - Test 5");
$m->logf("%s %s - %s", [ "Test 3", "Test 4", "Test 5" ], "debug");
$t->end("`logf` produced debug output as expected");

done_testing();

