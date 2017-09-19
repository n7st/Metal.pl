#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use Getopt::Long qw(GetOptions);

use lib "$FindBin::RealBin/../lib";

use Metal;

GetOptions('config|c=s' => \my $config);

$config ||= 'data/config.yml';

my $metal = Metal->new({
    config_file => $config,
});

exit $metal->run();

