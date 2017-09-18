package Metal::Module::Ping;

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

