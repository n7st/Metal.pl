#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use Getopt::Long qw(GetOptions);

use lib "$FindBin::RealBin/../lib";

use Metal;

GetOptions('config|c=s' => \my $config);

$config ||= 'data/config.yml';

# For access later
$ENV{METAL_CFG_FILE} = $config;

my $metal = Metal->new({
    config_file => $config,
});

exit $metal->run();

