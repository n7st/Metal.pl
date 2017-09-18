package Metal::Module::Core::Connection;

use Moose;

extends 'Metal::Module';
with    'Metal::Role::Logger';

################################################################################

sub disconnect {
    my $self = shift;
    my $args = shift;
    my $poe  = shift;

    $self->logger->info("Bot disconnecting");

    $poe->{kernel}->post(quit => 'Disconnecting');

    $self->logger->info("Closing the program");

    exit;
}

sub reconnect {
    my $self = shift;
    my $args = shift;
    my $poe  = shift;

    $self->logger->info("Bot reconnecting");

    $poe->{heap}->{irc}->yield('connect');

    return 1;
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Module::Core::Connection

=head1 DESCRIPTION

Handle the bot's IRC connection.

=head2 METHODS

=over 4

=item C<disconnect()>

Disconnect from the network and exit the program (or we're left in limbo).

=item C<reconnect()>

Reconnect to the network.

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

