package Metal::Input;

use Data::Printer;
use Encode;
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

    my $bot      = $heap->{irc};
    my $s_config = $self->config->{server};
    my $password = $s_config->{server_password};

    $kernel->post($bot => register => 'all');

    $kernel->post($bot => connect => {
        Ircname  => $s_config->{realname},
        Nick     => $s_config->{nickname},
        Port     => $s_config->{port},
        Server   => $s_config->{host},
        Username => $s_config->{ident},
        Password => $password,
        UseSSL   => $s_config->{ssl} // 0,
        debug    => $s_config->{debug} // 0,
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

    if ($self->config->{server}->{ns_password}) {
        $kernel->post($bot => privmsg => 'nickserv' => sprintf(
                "identify %s",
                $self->config->{server}->{ns_password},
            )
        );
    }

    sleep 5;

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

    my $args = $self->args_as_hashref('PUBLIC', @_);

    return if $args->{from}->{nick} eq $self->config->{server}->{nickname};

    $self->_handle_command($kernel, $heap->{irc}, $args);
    $self->_message_log('PUBLIC', $args);

    return;
}

sub irc_msg {
    my $self    = shift;
    my $session = shift;
    my $kernel  = shift;
    my $heap    = shift;

    my $args = $self->args_as_hashref('PRIVATE', @_);

    return if $args->{from}->{nick} eq $self->config->{server}->{nickname};

    $self->_handle_command($kernel, $heap->{irc}, $args);
    $self->_message_log('PRIVATE', $args);

    return;
}

sub irc_notice {
    my $self    = shift;
    my $session = shift;
    my $kernel  = shift;
    my $heap    = shift;

    my $args = $self->args_as_hashref('NOTICE', @_);

    return if $args->{from}->{nick} eq $self->config->{server}->{nickname};

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

    # $output already seems to be a utf8 string when it reaches here but when
    # posted through $kernel the strings are broken - FIXME
    $output = decode_utf8($output);

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

