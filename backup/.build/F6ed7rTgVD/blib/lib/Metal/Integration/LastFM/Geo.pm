package Metal::Integration::LastFM::Geo;

use Moose;

extends 'Metal::Integration::LastFM';

################################################################################

sub favourite {
    my $self    = shift;
    my $country = shift;

    return { error => 1, summary => 'Country name required' } unless $country;

    my $response = $self->_get_query('geo.getTopArtists', {
        country => $country,
        limit   => 10,
    });

    return {
        summary => $response->{message},
        error   => $response->{error},
    } if $response->{error};

    my @artists = map { $_->{name} } @{$response->{topartists}->{artist}};

    return {
        summary => join(', ', @artists),
        artists => \@artists,
        error   => 0,
    };
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;

