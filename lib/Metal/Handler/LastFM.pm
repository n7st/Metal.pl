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

    unless ($user) {
        return $self->error_codes->{no_user};
    }

    my $resp = $self->_get_query('user.getRecentTracks', {
        user     => $user,
        limit    => 1,
        extended => 1,
    });

    my $track    = $resp->{recenttracks}->{track}->[0];
    my $attr     = $track && $resp->{recenttracks}->{'@attr'};
    my $album    = $track && $track->{album}->{'#text'};
    my $title    = $track && $track->{name};
    my $artist   = $track && $track->{artist}->{name};
    my $scrobble = $attr  && $attr->{total};

    my $np = $attr && $attr->{nowplaying}
        ? 'is now playing'
        : 'last played';

    return sprintf("%s %s: %s/%s (%s)",
        $user,
        $np,
        $artist,
        $title,
        $album,
    );
}

sub artist_info {
    my $self = shift;

    my $resp = $self->_get_query('artist.getInfo', {
        artist      => $self->args->{string},
        autocorrect => 1,
    });

    return $resp->{message} if $resp->{error};

    my $artist  = $resp->{artist};
    my $stats   = $artist->{stats};
    my (@similar_artists, @related_tags);

    push @similar_artists, $_->{name} foreach @{$artist->{similar}->{artist}};
    push @related_tags,    $_->{name} foreach @{$artist->{tags}->{tag}};

    return sprintf("%s have %d plays and %d listeners. Similar artists: %s. Tags: %s.",
        $artist->{name},
        $stats->{playcount},
        $stats->{listeners},
        join(', ', @similar_artists) || '(none)',
        join(', ', @related_tags)    || '(none)',
    );
}

sub user_info {
    my $self = shift;
    my $ircu = shift;

    my $user = $self->args->{list}->[0]
        ? $self->args->{list}->[0]
        : $ircu->lastfm;

    unless ($user) {
        return $self->error_codes->{no_user};
    }

    my $resp = $self->_get_query('user.getInfo', {
        user => $user,
    });

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

