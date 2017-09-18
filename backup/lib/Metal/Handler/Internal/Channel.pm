package Metal::Handler::Internal::Channel;

use Moose;

extends 'Metal::Handler';
with    'Metal::Role::Logger';

################################################################################

sub join_channel {
    my $self    = shift;
    my $session = shift;
    my $kernel  = shift;
    my $heap    = shift;
    my $args    = pop;

    return unless $args->{channel};

    $self->logger->info("Joining ".$args->{channel});

    my $join_type = $args->{ojoin} ? 'ojoin' : 'join';

    $kernel->post($heap->{irc} => $join_type => $args->{channel});

    if ($args->{then}) {
        my $next = shift @{$args->{then}};

        $kernel->delay($next => 1, $args);
    }

    return 1;
}

sub message_channel {
    my $self    = shift;
    my $session = shift;
    my $kernel  = shift;
    my $heap    = shift;
    my $args    = pop;

    return unless $args->{with}->{message};

    $self->logger->info("Messaging ".$args->{channel}." with ".$args->{with}->{message});

    $kernel->post($heap->{irc} => 'privmsg' => $args->{channel} => $args->{with}->{message});

    if ($args->{then}) {
        my $next  = shift @{$args->{then}};
        my $delay = $next eq 'part_channel' ? 5 : 1;

        # Occasionally, without a delay, we'll part too early
        $kernel->delay($next => $delay, $args);
    }

    return 1;
}

sub part_channel {
    my $self    = shift;
    my $session = shift;
    my $kernel  = shift;
    my $heap    = shift;
    my $args    = pop;

    return unless $args->{channel};

    $kernel->post($heap->{irc} => part => $args->{channel});

    return 1;
}

################################################################################

sub _build_events {
    return {
        join_channel    => 1,
        message_channel => 1,
        part_channel    => 1,
    };
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Handler::Internal::Channel

=head1 DESCRIPTION

=head2 METHODS

=over 4

=item C<join_channel()>

Join a channel.

=item C<message_channel()>

Message a channel.

=item C<part_channel()>

Part a channel.

=item C<_build_events()>

Build a list of events handled by this package to be read in the program's
main package.

=back

