package Metal::Module::LastFM;

use DDP;
use List::MoreUtils qw(any);
use Moose;

use Metal::Integration::LastFM::Artist;
use Metal::Integration::LastFM::Geo;

extends 'Metal::Module';

################################################################################

has api_key  => (is => 'ro', isa => 'Str',                                lazy_build => 1);
has artist   => (is => 'ro', isa => 'Metal::Integration::LastFM::Artist', lazy_build => 1);
has commands => (is => 'ro', isa => 'HashRef',                            lazy_build => 1);
has geo      => (is => 'ro', isa => 'Metal::Integration::LastFM::Geo',    lazy_build => 1);

################################################################################

sub on_bot_public {
    my $self  = shift;
    my $event = shift;

    my $command     = $event->{args}->{command};
    my $artist_name = $event->{args}->{message_arg_str};
    my $output;

    if ($self->commands->{$command}) {
        my $subroutine = $self->commands->{$command};

        $output = $self->$subroutine($event->{args});
    }

    $self->bot->message_channel($event->{args}->{channel}, $output);

    return 1;
}

################################################################################

sub _artist_info {
    my $self = shift;
    my $args = shift;

    return $self->artist->info($args->{message_arg_str})->{summary};
}

sub _artist_similar {
    my $self = shift;
    my $args = shift;

    my $artist_name = $args->{message_arg_str};
    my $similar     = $self->artist->info($artist_name)->{similar};

    if ($similar) {
        return sprintf('Similar artists to %s: %s', $artist_name, $similar);
    } else {
        return sprintf('%s have no similar artists', $artist_name);
    }
}

sub _artist_tags {
    my $self = shift;
    my $args = shift;

    my $artist_name = $args->{message_arg_str};
    my $tags        = $self->artist->info($artist_name)->{tags};

    if ($tags) {
        return sprintf('Tags for %s: %s', $artist_name, $tags);
    } else {
        return sprintf('%s have no tags', $artist_name);
    }
}

sub _geo_favourite {
    my $self = shift;
    my $args = shift;

    my $country = $args->{message_arg_str};
    my @uk      = ('England', 'Northern Ireland', 'Scotland', 'Wales');

    if (any { $_ eq $country } @uk) {
        $country = 'United Kingdom';
    }

    my $favourites = $self->geo->favourite($country)->{summary};

    if ($favourites eq 'country param invalid') {
        return 'Invalid country provided';
    }

    if ($favourites) {
        return sprintf('Favourite artists for %s: %s', $country, $favourites);
    } else {
        return sprintf('No favourite artists available for %s', $country);
    }
}

################################################################################

sub _build_api_key {
    my $self = shift;

    return $self->bot->config->{lastfm}->{api_key};
}

sub _build_artist {
    my $self = shift;

    return Metal::Integration::LastFM::Artist->new({
        api_key => $self->api_key,
    });
}

sub _build_commands {
    my $self = shift;

    return {
        # Artist
        artist  => '_artist_info',
        similar => '_artist_similar',
        tags    => '_artist_tags',

        # Geo
        geotop => '_geo_favourite',

        # Album

        # User
    };
}

sub _build_geo {
    my $self = shift;

    return Metal::Integration::LastFM::Geo->new({
        api_key => $self->api_key,
    });
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;

