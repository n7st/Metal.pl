package Metal::Integration::LastFM::Artist;

use Moose;

extends 'Metal::Integration::LastFM';

################################################################################

sub info {
    my $self = shift;
    my $name = shift;

    return { error => 1, summary => 'Artist name required' } unless $name;

    my $response = $self->_get_query('artist.getInfo', {
        artist      => $name,
        autocorrect => 1,
    });

    return {
        summary => $response->{message},
        error   => $response->{error},
    } if $response->{error};

    my $artist = $response->{artist};
    my $stats  = $artist->{stats};
    my @similar = map { $_->{name} } @{$artist->{similar}->{artist}};
    my @tags    = map { $_->{name} } @{$artist->{tags}->{tag}};

    my %info = (
        listeners => $stats->{listeners},
        name      => $artist->{name},
        playcount => $stats->{playcount},
        tags      => join(', ', @tags)    // 'none',
        similar   => join(', ', @similar) // 'none',
    );

    return {
        summary => $self->_info_summary(\%info),   
        error   => 0,

        %info,
    };
}

################################################################################

sub _info_summary {
    my $self = shift;
    my $info = shift;

    return sprintf('%s have %d plays and %d listeners. Similar artists: %s. Tags: %s.',
        $info->{name},
        $info->{playcount},
        $info->{listeners},
        $info->{similar},
        $info->{tags},
    );
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;

