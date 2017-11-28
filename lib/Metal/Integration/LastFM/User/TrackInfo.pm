package Metal::Integration::LastFM::User::TrackInfo;

use Moose;

################################################################################

has track_data => (is => 'ro', isa => 'HashRef', required => 1);
has username   => (is => 'ro', isa => 'Str',     required => 1);

has [ qw(
    artist_data
    user_track_data
) ] => (is => 'ro', isa => 'HashRef', required => 0);

has [ qw(
    album
    artist
    now_playing_desc
    output
    tags
    title
) ] => (is => 'ro', isa => 'Str', lazy_build => 1);

has [ qw(
    artist_tags
    track_tags
) ] => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);

has is_now_playing => (is => 'ro', isa => 'Bool', lazy_build => 1);
has playcount      => (is => 'ro', isa => 'Int',  lazy_build => 1);

################################################################################

sub _build_artist {
    my $self = shift;

    return $self->track_data->{artist}->{name};
}

sub _build_album {
    my $self = shift;

    return $self->track_data->{album}->{'#text'};
}

sub _build_title {
    my $self = shift;

    return $self->track_data->{name};
}

sub _build_now_playing_desc {
    my $self = shift;

    return $self->is_now_playing ? 'is now playing' : 'last played';
}

sub _build_tags {
    my $self = shift;

    if (scalar @{$self->track_tags}) {
        return join(', ', @{$self->track_tags});
    } elsif (scalar @{$self->artist_tags}) {
        return join(', ', @{$self->artist_tags});
    }

    return 'none';
}

sub _build_output {
    my $self = shift;

    return sprintf(q[%s %s %s "%s" (%s) [%dx] (%s)],
        $self->username,
        $self->now_playing_desc,
        $self->artist,
        $self->title,
        $self->album,
        $self->playcount,
        $self->tags,
    );
}

sub _build_is_now_playing {
    my $self = shift;

    my $info = $self->track_data->{'@attr'};

    return $info && $info->{nowplaying} && $info->{nowplaying} eq 'true';
}

sub _build_playcount {
    my $self = shift;

    my $playcount = $self->user_track_data && $self->user_track_data->{userplaycount};

    return $playcount || 0;
}

sub _build_artist_tags {
    my $self = shift;

    return [] unless $self->artist_data;
    return [ map { $_->{name} } @{$self->artist_data->{tags}->{tag}} ];
}

sub _build_track_tags {
    my $self = shift;

    return [ map { $_->{name} } @{$self->track_data->{toptags}->{tag}} ];
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;

