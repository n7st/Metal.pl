package Metal::Module;

use Moose;
use Reflex::Trait::Watched qw(watches);

extends 'Reflex::Base';

################################################################################

has bot => (is => 'ro', isa => 'Metal::IRC', required => 1);

watches bot_watcher => (is => 'rw', isa => 'Metal::IRC', role => 'bot');

################################################################################

sub BUILD {
    my $self = shift;

    $self->bot_watcher($self->bot);

    return 1;
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;

