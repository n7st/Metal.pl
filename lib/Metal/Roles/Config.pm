package Metal::Roles::Config;

use Moose::Role;
use YAML::Syck;

################################################################################

has config => (is => 'ro', isa => 'HashRef', lazy_build => 1);

use constant {
    CONFIG_FILE => './data/config.yml',
};

################################################################################

sub _build_config {
    my $self = shift;

    # TODO allow custom path

    return LoadFile($self->CONFIG_FILE) if -e $self->CONFIG_FILE;
    return {};
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Roles::Config

=head1 DESCRIPTION

Operations relating to static YAML config file.

=head1 AUTHOR

Mike Jones <mike@netsplit.org.uk>

