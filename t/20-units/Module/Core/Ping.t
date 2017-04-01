#!/usr/bin/env perl

use strict;
use warnings;

use Data::Printer;
use FindBin;
use Test::More tests => 2;

use lib "$FindBin::RealBin/../../../../lib";

use_ok('Metal::Module::Core::Ping') || BAIL_OUT("Can't load class to test!");

my $p = Metal::Module::Core::Ping->new();

$p->ping();

is($p->reply->[0], "Pong", "Response as expected");

done_testing();
__END__

=head1 NAME

t/20-units/Module/Core/Ping.t

=head1 DESCRIPTION

Ensure the ping module response is correct.

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

