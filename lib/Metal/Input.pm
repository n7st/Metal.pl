package Metal::Input;

use Data::Printer;
use Moose;

extends 'Metal';

with qw/
    Metal::Roles::Argument::Handler
    Metal::Roles::Routes
    Metal::Roles::DB
/;

################################################################################

has args => (is => 'rw', isa => 'HashRef');

################################################################################

sub _start {
    my $self    = shift;
    my $session = shift;
    my $kernel  = shift;
    my $heap    = shift;

    my $bot = $heap->{irc};

    $kernel->post($bot => register => 'all');

    $kernel->post($bot => connect => {
        Ircname  => $self->config->{server}->{ircname},
        Nick     => $self->config->{server}->{nickname},
        Port     => $self->config->{server}->{port},
        Server   => $self->config->{server}->{host},
        Username => $self->config->{server}->{ident},
    });

    print STDOUT "[SYSTEM] Connected\n";

    return;
}

sub irc_001 {
    my $self    = shift;
    my $session = shift;
    my $kernel  = shift;
    my $heap    = shift;

    my $bot = $heap->{irc};

    foreach (@{$self->config->{channels}}) {
        $kernel->post($bot => join => $_);
    }

    return;
}

sub irc_public {
    my $self    = shift;
    my $session = shift;
    my $kernel  = shift;
    my $heap    = shift;

    my $args = $self->args_as_hashref(@_);

    $self->_handle_command($kernel, $heap->{irc}, $args);
    $self->_message_log('PUBLIC', $args);

    return;
}

sub irc_private {
    my $self    = shift;
    my $session = shift;
    my $kernel  = shift;
    my $heap    = shift;

    my $args = $self->args_as_hashref(@_);

    $self->_message_log('PRIVATE', $args);

    return;
}

sub irc_notice {
    my $self    = shift;
    my $session = shift;
    my $kernel  = shift;
    my $heap    = shift;

    my $args = $self->args_as_hashref(@_);

    $self->_message_log('NOTICE', $args);

    return;
}

sub test_input {
    my $self    = shift;
    my $command = shift;
    my $args    = shift;

    my $command_info = $self->routes->{$command};
    my $output;

    if ($command_info) {
        my $class   = $command_info->{class}->new({ args => $args });
        my $routine = $command_info->{routine};

        $output = $class->$routine();
    }

    return $output;
}

################################################################################

sub _handle_command {
    my $self   = shift;
    my $kernel = shift;
    my $bot    = shift;
    my $args   = shift;

    my $cmd = $args->{list_with_cmd}->[0];
    my $output;

    return unless $cmd && $cmd =~ /^$self->{config}->{trigger}/;
    # i.e. !command where trigger is '!'

    $cmd =~ s/^.//;

    # Metal::Roles::Routes
    my $handle = $self->routes->{$cmd};

    if ($handle) {
        my $class   = $handle->{class}->new({ args => $args });
        my $routine = $handle->{routine};

        $output = $class->$routine();
    }

    if ($output) {
        $kernel->post($bot => privmsg => $args->{input_location} => $output);
    }

    return;
}

sub _message_log {
    my $self = shift;
    my $type = shift;
    my $args = shift;

    printf STDOUT (
        "[%s] %s (%s): %s\n",
        $type,
        $args->{from}->{nick},
        $args->{from}->{host},
        $args->{original},
    );

    return;
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Input

=head1 DESCRIPTION

Converts signals passed by POE::Component::IRC into commands which may be in
Metal::Roles::Routes.

=head1 SEE ALSO

=over 4

=item C<Metal::Roles::Routes>

Mapping hash for command => class, method.

=back

=head1 AUTHOR

Mike Jones <mike@netsplit.org.uk>

