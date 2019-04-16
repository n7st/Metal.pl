package Metal::Role::Config;

use Moose::Role;

use Metal::Util::Config;

################################################################################

has config      => (is => 'ro', isa => 'HashRef',             lazy_build => 1);
has config_util => (is => 'ro', isa => 'Metal::Util::Config', lazy_build => 1);

################################################################################

sub _build_config_util {
    return Metal::Util::Config->new({
        filename => $ENV{METAL_CFG_FILE},
    });
}

sub _build_config {
    my $self = shift;

    return $self->config_util->config;
}

################################################################################

no Moose::Role;
1;

