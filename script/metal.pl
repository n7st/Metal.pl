#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use Getopt::Long 'GetOptions';

use lib "$FindBin::RealBin/../lib";

use Metal;

binmode STDOUT, ':encoding(UTF-8)'; # quiet warnings about wide characters by
binmode STDERR, ':encoding(UTF-8)'; # setting the console's encoding to UTF8

GetOptions('config|c=s' => \my $config);

$config ||= 'data/config.yml';

# For access later
$ENV{METAL_CFG_FILE} = $config;

my $metal = Metal->new();

exit $metal->run();

