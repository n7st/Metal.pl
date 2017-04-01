package Metal::Handler::External::IRC;

use Moose;

use Metal::Module::Core::Connection;

extends 'Metal::Handler';
with    qw/
    Metal::Role::Config
    Metal::Role::Logger
/;

################################################################################

sub _start {
    my $self    = shift;
    my $session = shift;
    my $kernel  = shift;
    my $heap    = shift;

    $kernel->post($heap->{irc} => 'register' => 'all');
    $kernel->post($heap->{irc} => 'connect' => {});

    return 1;
}

sub irc_001 {
    my $self    = shift;
    my $session = shift;
    my $kernel  = shift;
    my $heap    = shift;

    if ($heap->{present}) {
        foreach (@{$self->config->{default_channels}}) {
            $self->logger->info("Joining ".$_);
            $kernel->post($heap->{irc} => 'join' => $_);
        }
    }

    return 1;
}

sub irc_disconnected {
    my $self    = shift;
    my $session = shift;
    my $kernel  = shift;
    my $heap    = shift;

    # Reconnect to the network

    my $m = Metal::Module::Core::Connection->new();

    $m->reconnect({}, {
        heap    => $heap,
        kernel  => $kernel,
        session => $session,
    });

    return 1;
}

################################################################################

sub _build_events {
    return {
        _start           => 1,
        irc_001          => 1,
        irc_disconnected => 1,
    };
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Handler::External::IRC

=head1 DESCRIPTION

Basic IRC events - connecting, welcome etc.

=head2 METHODS

=over 4

=item C<_start()>

First event called when the bot is started.

=item C<irc_001()>

RPL_WELCOME - first message sent by the network.

=back

