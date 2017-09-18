package Reflex::Event::NamedArgument;

$Reflex::Event::NamedArgument::VERSION = 0.100;

use Moose;

extends 'Reflex::Event';

################################################################################

has args => (is => 'ro', isa => 'HashRef[Any]', default => sub { {} });

################################################################################

no Moose;
__PACKAGE__->make_event_cloner();
__PACKAGE__->meta->make_immutable();
1;
__END__

=head1 NAME

Reflex::Event::NamedArgument - pass a HashRef of arguments to a Reflex event.

=head1 DESCRIPTION

Allows a HashRef of arguments to be passed as part of a Reflex event.

=head2 USAGE

    use Reflex::Event::WithArguments;

    sub on_some_event {
        my $self  = shift;
        my $event = shift;

        $self->emit(
            -name => 'public',
            -type => 'Reflex::Event::WithArguments',
            event => 'public',
            args => {
                foo => 'bar',
            },  
        ); 
    }

=head1 VERSION

0.100

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

