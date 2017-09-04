#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use Test::More;

use lib "$FindBin::RealBin/../../lib";

use Metal::Util::Config;
use Metal::Integration::LastFM::Artist;

require_ok('Metal::Integration::LastFM::Artist') || BAIL_OUT('Base module could not be included');
require_ok('Metal::Util::Config')                || BAIL_OUT('Config module could not be included');

ok(my $config_util = Metal::Util::Config->new({
    filename => './data/config.yml',
}), 'Config initialisation') || BAIL_OUT('Missing config file (./data/config.yml)');

my $api_key = $config_util->config->{lastfm}->{api_key};

SKIP: {
    skip 'No Last.FM API key was found in the config file (lastfm:api_key)', 2 unless $api_key;

    ok(my $artist = Metal::Integration::LastFM::Artist->new({
        api_key => $api_key,
    }), 'Artist initialisation');

    # Send an empty artist string -- we can't realistically test data returned
    # from the API, but the integration will still spit out a summary.
    my $info = $artist->info('');

    isnt($info->{summary}, undef, 'Artist summary existence check');
};

done_testing();

