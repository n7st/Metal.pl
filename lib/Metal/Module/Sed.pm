package Metal::Module::Sed;

use Moose;

extends 'Metal::Module';
with    'Metal::Role::Logger';

################################################################################

has commands => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);

has history => (is => 'rw', isa => 'HashRef', traits => [ 'Hash' ], handles => {
    set_history => 'set',
    get_history => 'get',
});

################################################################################

sub on_bot_public {
    my $self  = shift;
    my $event = shift;

    my $output;

    foreach my $command (@{$self->commands}) {
        if (my ($old, $new) = $event->{args}->{$command->{location}} =~ $command->{regex}) {
            my $method = $command->{method};

            $output = $self->$method($event->{args}->{channel}, $old, $new);
        }
    }

    $self->bot->message_channel($event->{args}->{channel}, $output);

    # Don't set substitution commands as the last message
    unless ($event->{args}->{message} =~ /^s\//) {
        $self->set_history($event->{args}->{channel}, $event->{args}->{message});
    }

    return 1;
}

################################################################################

sub _sed {
    my $self    = shift;
    my $channel = shift;
    my $old     = shift;
    my $new     = shift;

    my $message = $self->get_history($channel);

    # Skip messages that don't match the given input
    return undef if $message !~ /\Q$old/;

    # \Q to avoid malicious input characters
    $message =~ s/\Q$old/$new/s;

    return "[=~] ${message}";
}

################################################################################

sub _build_commands {
    return [{
        method   => '_sed',
        location => 'message',
        regex    => qr{^s/([^/].+)/(.+[^/]).*$},
    }];
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;

