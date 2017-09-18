package Metal::Role::REST;

use JSON::XS    qw(decode_json);
use LWP::Simple qw(get);
use Moose::Role;

################################################################################

sub rest_get {
    my $self = shift;
    my $args = shift;

    return decode_json(get($args->{url}));
}

################################################################################

no Moose;
1;

