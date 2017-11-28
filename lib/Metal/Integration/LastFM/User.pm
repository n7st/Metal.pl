package Metal::Integration::LastFM::User;

use Data::Printer;
use Moose;

use Metal::Integration::LastFM::User::TrackInfo;

extends 'Metal::Integration::LastFM';
with    'Metal::Role::Maths';

################################################################################

has top_limit => (is => 'ro', isa => 'Int', default => 8);

################################################################################

sub album_plays {
    my $self   = shift;
    my $user   = shift;
    my $artist = shift;
    my $album  = shift;

    my $response = $self->_get_query('album.getInfo', {
        album       => $album,
        artist      => $artist,
        autocorrect => 1,
        user        => $user,
    });

    return {
        summary => $response->{message},
        error   => $response->{error},
    } if $response->{error};

    my $info = $response->{album};
    my ($user_playcount, $playcount, $percentage) = $self->_get_playcount_data($info);

    my $summary = sprintf("%s/%s has %d total plays, of which %d are %s's (%s%%).",
        $info->{artist}, $info->{name}, $playcount, $user_playcount, $user, $percentage);

    return {
        error      => 0,
        summary    => $summary,
        playcounts => {
            user  => $user_playcount,
            total => $playcount,
        },
    };
}

sub song_plays {
    my $self   = shift;
    my $user   = shift;
    my $artist = shift;
    my $song   = shift;

    my $response = $self->_get_query('track.getInfo', {
        username => $user, # Not "user" as for album.getInfo
        artist   => $artist,
        track    => $song,
    });

    return {
        summary => $response->{message},
        error   => $response->{error},
    } if $response->{error};

    my $info = $response->{track};

    my ($user_playcount, $playcount, $percentage) = $self->_get_playcount_data($info);

    my $summary = sprintf("%s by %s has %d total plays, of which %d are %s's (%s%%)",
        $info->{name}, $info->{artist}->{name}, $playcount, $user_playcount, $user, $percentage);

    return {
        error      => 0,
        summary    => $summary,
        playcounts => {
            user  => $user_playcount,
            total => $playcount,
        },
    };
}

sub artist_plays {
    my $self   = shift;
    my $user   = shift;
    my $artist = shift;

    my $response = $self->_get_query('artist.getInfo', {
        artist      => $artist,
        user        => $user,
        autocorrect => 1,
    });

    return {
        summary => $response->{message},
        error   => $response->{error},
    } if $response->{error};

    my $info = $response->{artist};
    my ($user_playcount, $playcount, $percentage) = $self->_get_playcount_data($info->{stats});

    my $summary = sprintf("%s have %s total plays, of which %d are %s's (%s%%).",
        $info->{name}, $playcount, $user_playcount, $user, $percentage);

    return {
        error      => 0,
        summary    => $summary,
        playcounts => {
            user  => $user_playcount,
            total => $playcount,
        },
    };
}

sub now_playing {
    my $self = shift;
    my $user = shift;

    return { error => 1, summary => 'Username required' } unless $user;

    my $response = $self->_get_query('user.getRecentTracks', {
        limit    => 1,
        user     => $user,
        extended => 1,
    });

    return {
        summary => $response->{message},
        error   => $response->{error},
    } if $response->{error};

    my $track = $response->{recenttracks}->{track}->[0];

    return {
        summary => "Error retrieving recent tracks for ${user}",
    } unless $track;

    my $extra = $self->_get_query('track.getInfo', {
        artist      => $track->{artist}->{name},
        autocorrect => 1,
        track       => $track->{name},
        username    => $user,
    });

    my $artist = $self->_get_query('artist.getInfo', {
        artist      => $track->{artist}->{name},
        autocorrect => 1,
        username    => $user,
    });

    return {
        error   => 1,
        summary => "No recent tracks for ${user}",
    } unless $track;

    my $track_info = Metal::Integration::LastFM::User::TrackInfo->new({
        artist_data     => $artist->{artist},
        track_data      => $track,
        user_track_data => $extra->{track} // {},
        username        => $user,
    });

    return {
        summary => $track_info->output,
        error   => 0,
        track   => $track_info,
    };
}

sub top {
    my $self   = shift;
    my $user   = shift;
    my $period = shift;

    my $response = $self->_get_query('user.getTopArtists', {
        username => $user,
        period   => $period,
        limit    => $self->top_limit,
    });

    return {
        summary => $response->{message},
        error   => $response->{error},
    } if $response->{error};

    my %periods = (
        'overall' => 'all time',
        '7day'    => 'the last week',
        '1month'  => 'the last month',
        '12month' => 'the last year',
    );

    my @artists = map {
        sprintf('%s [%d]', $_->{name}, $_->{playcount})
    } @{$response->{topartists}->{artist}};

    return {
        artists => \@artists,
        summary => sprintf(q[%s's top artists for %s: %s],
            $user,
            $periods{$period},
            join(', ', @artists) || 'none',
        ),
    };
}

################################################################################

sub _get_playcount_data {
    my $self = shift;
    my $node = shift;

    my $user_playcount = $node->{userplaycount};
    my $playcount      = $node->{playcount};
    my $percentage     = $self->percentage($user_playcount, $playcount);

    return ($user_playcount, $playcount, $percentage);
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;

