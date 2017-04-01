package Metal::Handler;

use Moose;

with 'Metal::Role::Logger';

################################################################################

has events => (is => 'ro', isa => 'HashRef', lazy_build => 1);
has type   => (is => 'ro', isa => 'Str',     lazy_build => 1);

################################################################################

sub _build_events {
    my $self = shift;

    $self->logger->warn("You must override _build_events in a Handler child class");

    return [];
}

sub _build_type { 'Event' }

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Handler

=head1 DESCRIPTION

Base class for Handler mapper classes.

=head2 METHODS

=over 4

=item C<_build_events()>

Must be overridden in a class extending this one and should contain events which
are handled by that class:

    sub _build_events {
        return [ 'join_channel', 'message_channel', 'part_channel' ];
    }

=item C<_build_type()>

Define the type of a handler. Available types:

    +-------+---------------------------------------------+
    | Type  | Description                                 |
    +-------+---------------------------------------------+
    | Event | Regular event handler (e.g. input from IRC) |
    | Task  | Events handled by the bot's inbuilt crontab |
    +-------+---------------------------------------------+

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

