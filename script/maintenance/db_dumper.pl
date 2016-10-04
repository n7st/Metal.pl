#!/usr/bin/perl -w
use strict;
use warnings;
use Modern::Perl;
use Getopt::Long;
use DBIx::Class::Schema::Loader qw/make_schema_at/;

my ($username, $password);

Getopt::Long::GetOptions(
    'u|username=s' => \$username,
    'p|password=s' => \$password,
);

die 'Missing username or password.' unless $username && $password;

make_schema_at('Metal::Schema', {
    debug          => 1,
    dump_directory => './lib',
}, [
    'dbi:mysql:dbname=Metal',
    $username,
    $password,
]);

exit 0;
__END__

