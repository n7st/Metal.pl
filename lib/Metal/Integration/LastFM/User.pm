package Metal::Integration::LastFM::User;

use Moose;

use Metal::Integration::LastFM::User::TrackInfo;

extends 'Metal::Integration::LastFM';

################################################################################

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

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;

