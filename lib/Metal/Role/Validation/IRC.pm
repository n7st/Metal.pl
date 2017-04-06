package Metal::Role::Validation::IRC;

use Moose::Role;
use Net::IP qw/ip_is_ipv4 ip_is_ipv6/;

################################################################################

has hostname_regex => (is => 'ro', isa => 'Regexp', lazy_build => 1);
has ident_regex    => (is => 'ro', isa => 'Regexp', lazy_build => 1);
has nickname_regex => (is => 'ro', isa => 'Regexp', lazy_build => 1);
has port_regex     => (is => 'ro', isa => 'Regexp', lazy_build => 1);

################################################################################

sub valid_hostname_or_ip {
    my $self  = shift;
    my $input = shift;

    return 0 unless $input;
    return 1 if ip_is_ipv4($input);
    return 1 if ip_is_ipv6($input);
    return 1 if $input =~ $self->hostname_regex;
    return 0;
}

sub valid_ident {
    my $self  = shift;
    my $ident = shift;

    return 0 unless $ident;
    return $ident =~ $self->ident_regex;
}

sub valid_nickname {
    my $self     = shift;
    my $nickname = shift;

    return 0 unless $nickname;
    return $nickname =~ $self->nickname_regex;
}

sub valid_port {
    my $self = shift;
    my $port = shift;

    return 0 unless $port;
    return $port =~ $self->port_regex;
}

################################################################################

sub _build_hostname_regex {
    return qr/^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/i;
}

sub _build_ident_regex {
    return qr/^[a-z0-9-_\\]{1,11}$/i;
}

sub _build_nickname_regex {
    return qr/^[\w\d\|\[\]\{\}_-\`]{1,28}$/i;
}

sub _build_port_regex {
    # Ports can contain a leading +
    return qr/^\+?\d{1,5}$/;
}

################################################################################

no Moose;
1;
__END__

