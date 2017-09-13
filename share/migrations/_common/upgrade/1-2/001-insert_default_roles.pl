#!/usr/bin/env perl

use strict;
use warnings;

use DateTime;
use DBIx::Class::Migration::RunScript;

my $now = DateTime->now->ymd;

migrate {
    shift->schema->resultset('Role')->populate([
        [ qw(name date_created date_modified) ],
        [ 'Admin', $now, $now ],
        [ 'User',  $now, $now ],
    ]);
};

