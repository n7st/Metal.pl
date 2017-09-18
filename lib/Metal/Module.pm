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

    # TODO: option for watching the POCO object for overrides

    $self->bot_watcher($self->bot);

    return 1;
}

################################################################################

sub _attempt_command {
    my $self = shift;
    my $args = shift;

    return unless $self->commands;

    my $command = $args->{command};

    return unless $command;

    if (my $method = $self->commands->{$command}) {
        return $self->$method($args);
    }

    return;
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;
__END__

=head1 NAME

Metal::Module - Base class for modules watching Metal::IRC.

=head1 DESCRIPTION

This module should be used as a base class for modules watching for events
emitted by C<Metal::IRC>. It has access back to the main loop through the
C<bot> attribute.

=head2 ATTRIBUTES

=over 4

=item C<bot>

Main 'bot' class for reverse access to IRC functionality. Also includes the
bot's database handle.

=item C<bot_watcher>

Reflex watcher to collect events emitted by C<Metal::IRC>. These can be caught
in this class or classes which extend it like so:

    sub on_bot_public {
        # Caught when the bot_watcher emits 'public'
    }

    sub on_bot_join {
        # Caught when the bot_watcher emits 'join'
    }

    # etc

=back

=head2 METHODS

=over 4

=item C<BUILD()>

Runtime method. Initialises the C<bot_watcher> attribute.

=item C<_attempt_command()>

If a C<commands> attribute exists in the child class, attempt to match a
requested command to a method in the class and run it.

=back

