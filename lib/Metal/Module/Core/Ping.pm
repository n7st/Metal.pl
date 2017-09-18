package Metal::Module::Core::Ping;

use Moose;

extends 'Metal::Module';

################################################################################

sub on_bot_public {
    my $self  = shift;
    my $event = shift;

    if ($event->{args}->{command} eq 'ping') {
        $self->bot->message_channel($event->{args}->{channel}, 'Pong.');
    }

    return 1;
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;
__END__

=head1 NAME

Metal::Module::Core::Ping

=head1 DESCRIPTION

=head2 METHODS

=over 4

=item C<on_bot_public()>

Watches for a 'ping' command and replies "pong".

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

