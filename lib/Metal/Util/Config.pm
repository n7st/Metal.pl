package Metal::Util::Config;

use Moose;
use YAML::Syck qw(LoadFile);

################################################################################

has config => (is => 'ro', isa => 'HashRef', lazy_build => 1);

has filename => (is => 'ro', isa => 'Str', required => 1);

has default_trigger => (is => 'ro', isa => 'Str', default => '!');

################################################################################

sub _build_config {
    my $self = shift;

    return LoadFile($self->filename);
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;

