#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use Test::More;

use lib "$FindBin::RealBin/../../lib";

require_ok('Metal::Integration::LastFM::Artist') || BAIL_OUT('Artist module could not be included');
require_ok('Metal::Integration::LastFM::User')   || BAIL_OUT('User module could not be included');
require_ok('Metal::Util::Config')                || BAIL_OUT('Config module could not be included');

ok(my $config_util = Metal::Util::Config->new({
    filename => './data/config.yml.example',
}), 'Config initialisation') || BAIL_OUT('Missing config file (./data/config.yml.example)');

my $api_key = $config_util->config->{lastfm}->{api_key};

SKIP: {
    skip 'No Last.FM API key was found in the config file (lastfm:api_key)', 4 unless $api_key;

    ok(my $artist = Metal::Integration::LastFM::Artist->new({
        api_key => $api_key,
    }), 'Artist initialisation');

    # Send an empty artist string -- we can't realistically test data returned
    # from the API, but the integration will still spit out a summary.
    my $info = $artist->info('');

    isnt($info->{summary}, undef, 'Artist summary existence check');

    ok(my $user = Metal::Integration::LastFM::User->new({
        api_key => $api_key,
    }), 'User initialisation');

    my $now_playing = $user->now_playing('ne7split');

    isnt($now_playing->{summary}, undef, 'Now playing summary existence check');
};

done_testing();

