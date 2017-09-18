#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use Test::More;

use lib "$FindBin::RealBin/../../lib";

use_ok('Metal') || BAIL_OUT("Can't load base class (Metal).");

my $m = Metal->new();

foreach my $plugin ($m->plugins) {
    use_ok($plugin);
}

done_testing();
__END__

=head1 NAME

t/10-env/use.t

=head1 DESCRIPTION

Check all of the modules under Metal's namespace compile and use OK.

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

