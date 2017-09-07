package Metal::Module::LastFM;

use DDP;
use List::MoreUtils qw(any);
use Moose;

use Metal::Integration::LastFM::Artist;
use Metal::Integration::LastFM::Geo;
use Metal::Integration::LastFM::User;

extends 'Metal::Module';

################################################################################

has api_key  => (is => 'ro', isa => 'Str',                                lazy_build => 1);
has commands => (is => 'ro', isa => 'HashRef',                            lazy_build => 1);
has artist   => (is => 'ro', isa => 'Metal::Integration::LastFM::Artist', lazy_build => 1);
has geo      => (is => 'ro', isa => 'Metal::Integration::LastFM::Geo',    lazy_build => 1);
has user     => (is => 'ro', isa => 'Metal::Integration::LastFM::User',   lazy_build => 1);

around [ qw(_now_playing _top_all _top_month _top_week _top_year) ] => sub {
    my $orig = shift;
    my $self = shift;
    my $args = shift;

    # Get the current user's Last.fm name or one they've provided in the message

    my $user = $args->{message_args}->[0];

    my $lastfm_username;

    if ($args->{message_args}->[0]) {
        $lastfm_username = $args->{message_args}->[0];
    } else {
        $lastfm_username = $self->bot->db->resultset('User')->search_rs({
            hostmask => $args->{hostmask},
        })->first->lastfm;
    }

    unless ($lastfm_username) {
        my $trigger = $self->bot->config->{trigger};

        # If there's no name, instead return a message without continuing on
        # to the important bit
        return "No Last.fm username specified - set yours with ${trigger}setuser username_here";
    }

    return $self->$orig($args, $lastfm_username);
};

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

sub _now_playing {
    my $self            = shift;
    my $args            = shift;
    my $lastfm_username = shift;

    return $self->user->now_playing($lastfm_username)->{summary};
}

sub _set_user {
    my $self = shift;
    my $args = shift;

    my $requested = $args->{message_args}->[0];
    my $user      = $self->bot->db->resultset('User')->from_hostmask($args);
    my $start     = 'Your Last.fm username was';

    $user->lastfm($requested);
    $user->update();

    if ($requested) {
        return sprintf(q[%s set as "%s"], $start, $user->lastfm);
    } else {
        return "${start} unset.";
    }
}

sub _top_all   { shift->_top('overall', @_) }
sub _top_month { shift->_top('1month',  @_) }
sub _top_week  { shift->_top('7day',    @_) }
sub _top_year  { shift->_top('12month', @_) }

sub _top {
    my $self            = shift;
    my $period          = shift;
    my $args            = shift;
    my $lastfm_username = shift;

    return $self->user->top($lastfm_username, $period)->{summary}
}

################################################################################

sub _build_api_key {
    my $self = shift;

    return $self->bot->config->{lastfm}->{api_key};
}

sub _build_commands {
    my $self = shift;

    return {
        # Artist
        artist  => '_artist_info',
        band    => '_artist_info',
        similar => '_artist_similar',
        tags    => '_artist_tags',

        # Geo
        geotop => '_geo_favourite',

        # Album

        # User
        l          => '_now_playing',
        nowplaying => '_now_playing',
        np         => '_now_playing',
        setuser    => '_set_user',
        lastfm     => '_set_user',
        topw       => '_top_week',
        topm       => '_top_month',
        topy       => '_top_year',
        topa       => '_top_all',
    };
}

sub _build_artist {
    my $self = shift;

    return Metal::Integration::LastFM::Artist->new({
        api_key => $self->api_key,
    });
}

sub _build_geo {
    my $self = shift;

    return Metal::Integration::LastFM::Geo->new({
        api_key => $self->api_key,
    });
}

sub _build_user {
    my $self = shift;

    return Metal::Integration::LastFM::User->new({
        api_key => $self->api_key,
    });
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;

