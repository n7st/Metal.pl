package Metal::Handler::Releases;

use Moose;
use LWP::Simple;
use JSON::XS;

with "Metal::Roles::Config";

sub today {
    my $self = shift;

    my $uri = $self->config->{apis}->{releases};

    return "API config value is missing" unless $uri;

    my $json    = get($uri);
    my $content = decode_json($json);

    return $content->{display};
}

no Moose;
__PACKAGE__->meta->make_immutable();
1;

