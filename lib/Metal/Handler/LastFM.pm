package Metal::Handler::LastFM;

use Data::Printer;
use DateTime;
use JSON;
use LWP::Simple qw/get/;
use Math::Round;
use Moose;

extends 'Metal::Handler';
with    qw/
    Metal::Roles::DB
    Metal::Roles::Config
    Metal::Roles::Math
    Metal::Roles::User
/;

################################################################################

has api_key     => (is => 'ro', isa => 'Str', lazy_build => 1);
has api_url     => (is => 'ro', isa => 'Str', lazy_build => 1);
has error_codes => (is => 'ro', isa => 'HashRef', lazy_build => 1);

has json => (is => 'ro', isa => 'JSON', default => sub { JSON->new(); });

################################################################################

around qw/
    _top
    add_user
    album_scrobble_count
    artist_scrobble_count
    now_playing
    user_info
/ => sub {
    my $orig = shift;
    my $self = shift;

    my $current_user = $self->user_from_host($self->{args}->{from});

    return $self->$orig(@_, $current_user);
};

################################################################################

sub add_user {
    my $self = shift;
    my $ircu = shift;

    my $username = $self->args->{list}->[0];
    my $output;

    unless ($username) {
        return "You must provide a username to set (setuser username).";
    }

    unless ($username =~ /^[A-Z0-9-_]{2,15}$/i) {
        return sprintf("%s is not a valid Last.fm username.", $username);
    }

    $ircu->lastfm($username);
    $ircu->update();

    return sprintf("%s is now associated with %s.", $ircu->name, $username);
}

sub now_playing {
    my $self = shift;
    my $ircu = shift;

    my $user = $self->args->{list}->[0]
        ? $self->args->{list}->[0]
        : $ircu->lastfm;

    return $self->error_codes->{no_user} unless $user;

    my $resp = $self->_get_query('user.getRecentTracks', {
        user     => $user,
        limit    => 1,
        extended => 1,
    });

    my $track       = $resp->{recenttracks}->{track}->[0];
    my $attr        = $track && $track->{'@attr'};
    my $album       = $track && $track->{album}->{'#text'};
    my $title       = $track && $track->{name};
    my $artist      = $track && $track->{artist}->{name};
    my $artist_info = $self->_artist_data($artist);
    my $track_info  = $self->_track_data($artist, $title, $user);

    my $np = $attr && $attr->{nowplaying} ? 'is now playing' : 'last played';

    use DDP; p $attr;

    return sprintf("%s %s: %s/%s (%s) [%dx] (%s)",
        $user,
        $np,
        $artist,
        $title,
        $album,
        $track_info->{user_playcount},
        $artist_info->{tags},
    );
}

sub artist_info {
    my $self = shift;

    my $resp = $self->_artist_data($self->args->{string});

    return $resp->{message} if $resp->{error};

    return sprintf("%s have %d plays and %d listeners. Similar artists: %s. Tags: %s.",
        $resp->{name},
        $resp->{playcount},
        $resp->{listeners},
        $resp->{similar},
        $resp->{tags},
    );
}

sub user_info {
    my $self = shift;
    my $ircu = shift;

    my $user = $self->args->{list}->[0]
        ? $self->args->{list}->[0]
        : $ircu->lastfm;

    return $self->error_codes->{no_user} unless $user;

    my $resp = $self->_get_query('user.getInfo', { user => $user });

    return $resp->{message} if $resp->{error};

    my $info       = $resp->{user};
    my $registered = DateTime->from_epoch(epoch => $info->{registered}->{unixtime});

    return sprintf("(%s/%s) Location: %s | Type: %s | Registered: %s | Scrobbles: %d",
        $info->{realname} || 'Unknown',
        $info->{name},
        $info->{country} || 'Unknown',
        ucfirst($info->{type}),
        $registered->ymd,
        $info->{playcount} || 0,
    );
}

sub album_scrobble_count {
    my $self = shift;
    my $ircu = shift;

    return $self->error_codes->{no_user} unless $ircu->lastfm;

    my ($artist, $album) = $self->args->{string} =~ /^(.+) "(.+)"$/;

    unless ($artist && $album) {
        return 'Format: aplays artist name "album name"';
    }

    my $resp = $self->_get_query('album.getInfo', {
        username    => $ircu->lastfm,
        artist      => $artist,
        album       => $album,
        autocorrect => 1,
    });

    return $resp->{message} if $resp->{error};

    # Artist and album stats are formed differently
    my $stats          = $resp->{album};
    my $user_playcount = $stats->{userplaycount};
    my $playcount      = $stats->{playcount};
    my $percentage     = $self->percentage($user_playcount, $playcount);

    return sprintf("%s/%s has %d total plays, of which %d are %s's (%s%%).",
        $stats->{artist},
        $stats->{name},
        $playcount,
        $user_playcount,
        $ircu->lastfm,
        $percentage,
    );
}

sub artist_scrobble_count {
    my $self = shift;
    my $ircu = shift;

    return $self->error_codes->{no_user}  unless $ircu->lastfm;
    return "You must provide a band name" unless $self->args->{string};

    my $resp = $self->_get_query('artist.getInfo', {
        artist      => $self->args->{string},
        user        => $ircu->lastfm,
        autocorrect => 1,
    });

    return $resp->{message} if $resp->{error};

    # Artist and album stats are formed differently
    my $user_playcount = $resp->{artist}->{stats}->{userplaycount};
    my $playcount      = $resp->{artist}->{stats}->{playcount};
    my $percentage     = $self->percentage($user_playcount, $playcount);

    return sprintf("%s have %d total plays, of which %d are %s's (%s%%).",
        $resp->{artist}->{name},
        $playcount,
        $user_playcount,
        $ircu->lastfm,
        $percentage,
    );
}

sub top_all   { shift->_top('overall'); }
sub top_month { shift->_top('1month');  }
sub top_week  { shift->_top('7day');    }
sub top_year  { shift->_top('12month'); }

################################################################################

sub _artist_data {
    my $self = shift;
    my $name = shift;

    my $resp = $self->_get_query('artist.getInfo', {
        artist      => $name,
        autocorrect => 1,
    });

    return {
        error   => $resp->{error},
        message => $resp->{message},
    } if $resp->{error};

    my $artist = $resp->{artist};
    my $stats  = $artist && $artist->{stats};
    my (@similar, @tags);

    push @similar, $_->{name} foreach @{$artist->{similar}->{artist}};
    push @tags,    $_->{name} foreach @{$artist->{tags}->{tag}};

    return {
        listeners => $stats->{listeners},
        name      => $artist->{name},
        playcount => $stats->{playcount},
        similar   => join(', ', @similar) || '(none)',
        tags      => join(', ', @tags)    || '(none)',
    };
}

sub _get_query {
    my $self     = shift;
    my $endpoint = shift;
    my $params   = shift;

    my @query;

    foreach (keys %{$params}) {
        push @query, sprintf("%s=%s", $_, $params->{$_});
    }

    my $url = sprintf("%s?api_key=%s&format=json&method=%s&%s",
        $self->api_url,
        $self->api_key,
        $endpoint,
        join '&', @query,
    );

    return $self->json->decode(get($url));
}

sub _top {
    my $self   = shift;
    my $period = shift;
    my $ircu   = shift;

    my $user = $self->args->{list}->[0]
        ? $self->args->{list}->[0]
        : $ircu->lastfm;

    my $resp = $self->_get_query('user.getTopArtists', {
        user   => $user,
        period => $period,
        limit  => 8,
    });

    return $resp->{message} if $resp->{error};

    my $top_artists = $resp->{topartists}->{artist};
    my @artists;

    my %periods = (
        'overall' => 'all time',
        '7day'    => 'the last week',
        '1month'  => 'the last month',
        '12month' => 'the last year',
    );

    foreach (@{$top_artists}) {
        push @artists, sprintf("%s [%d]", $_->{name}, $_->{playcount});
    }

    return sprintf("%s's top artists for %s: %s",
        $user,
        $periods{$period},
        join(', ', @artists),
    );
}

sub _track_data {
    my $self   = shift;
    my $artist = shift;
    my $title  = shift;
    my $user   = shift;

    my $params = {
        artist => $artist,
        track  => $title,
    };

    $params->{user} = $user if $user;

    my $resp  = $self->_get_query('track.getInfo', $params);
    my $track = $resp->{track};

    return {
        playcount      => $track->{playcount}     || 0,
        user_playcount => $track->{userplaycount} || 0,
    };
}

################################################################################

sub _build_api_key { shift->config->{'keys'}->{lastfm};   }
sub _build_api_url { 'http://ws.audioscrobbler.com/2.0/'; }

sub _build_error_codes {
    return {
        no_user => 'No user specified (set one with "setuser username" or check another with "l username").',
    };
}

################################################################################

no Moose;
1;

