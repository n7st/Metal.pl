#!/usr/bin/env perl

use Test::More tests => 3;

BEGIN {
    use_ok('Metal');
    use_ok('Metal::Schema');
    use_ok('Metal::IRC');
};

