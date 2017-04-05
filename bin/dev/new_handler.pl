#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use Getopt::Long;

use lib "$FindBin::RealBin/../../lib";

use Metal::Handler::Creator;

################################################################################

my ($handler, $type);

Getopt::Long::GetOptions(
    'handler|h=s' => \$handler,
    'type|t=s'    => \$type,
);

die "No handler!" unless $handler;

my $nh = Metal::Handler::Creator->new({
    name => $handler,
    type => $type,
});

$nh->generate();

################################################################################

exit 0;
__END__

=head1 NAME

script/dev/new_handler.pl

=head1 DESCRIPTION

Create a new Metal Handler class in a specified namespace with boilerplate POD
and base methods.

=head2 USAGE

    perl script/dev/new_handler -h Internal::New::Handler [-t SomeType]

Where 'Internal::New::Handler' is the new class you would like to create.

