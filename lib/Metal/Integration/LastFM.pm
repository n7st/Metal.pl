package Metal::Integration::LastFM;

use JSON::XS    qw(decode_json);
use LWP::Simple qw(get);
use Moose;

with 'Metal::Role::Logger';

################################################################################

has api_key => (is => 'ro', isa => 'Str', required => 1);

has base_url => (is => 'ro', isa => 'Str', lazy_build => 1);

################################################################################

sub _get_query {
    my $self     = shift;
    my $endpoint = shift;
    my $args     = shift;

    my @query = map { sprintf('%s=%s', $_, $args->{$_}) } keys %{$args};

    my $url = sprintf("%s?method=%s&api_key=%s&format=json&%s",
        $self->base_url,
        $endpoint,
        $self->api_key,
        join('&', @query),
    );

    my $response = get($url);

    my $error_ret = { error => 1, message => 'API call failed!' };

    return $error_ret unless $response;

    my $ret;

    eval { $ret = decode_json($response) };
    $self->logger->warn($@) if $@;

    return $ret || $error_ret;
}

################################################################################

sub _build_base_url {
    return 'http://ws.audioscrobbler.com/2.0/';
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;

