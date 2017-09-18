package Metal::Role::Config;

use YAML::Syck;
use Moose::Role;

use constant CONFIG_FILE => './data/config.yml';

################################################################################

has config => (is => 'ro', isa => 'HashRef', lazy_build => 1);

################################################################################

sub _build_config {
    my $self = shift;

    return LoadFile($self->CONFIG_FILE) if -e $self->CONFIG_FILE;
    return {};
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Role::Config

=head1 DESCRIPTION

Read the YAML config file.

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

