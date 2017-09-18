package Metal::Handler::External::Message;

use Moose;

extends 'Metal::Handler';
with    'Metal::Handler::Role::Module';

################################################################################

around qw/irc_public irc_msg irc_notice/ => sub {
    my $orig    = shift;
    my $self    = shift;
    my $session = shift;
    my $kernel  = shift;
    my $heap    = shift;

    return $self->$orig($session, $kernel, $heap, {
        from     => $self->_format_from($_[6]),
        message  => $self->_format_message($_[8]),
        location => $_[7][0],
        type     => $orig,
    });
};

################################################################################

sub irc_public {
    my $self    = shift;
    my $session = shift;
    my $kernel  = shift;
    my $heap    = shift;
    my $args    = shift;

    $self->_handle_command('PUBLIC', {
        session => $session,
        kernel  => $kernel,
        heap    => $heap,
    }, $args);

    return 1;
}

sub irc_msg {
    my $self    = shift;
    my $session = shift;
    my $kernel  = shift;
    my $heap    = shift;
    my $args    = shift;

    $self->_handle_command('PRIVATE', {
        session => $session,
        kernel  => $kernel,
        heap    => $heap,
    }, $args);

    return 1;
}

sub irc_notice {
    my $self    = shift;
    my $session = shift;
    my $kernel  = shift;
    my $heap    = shift;
    my $args    = shift;

    $self->_handle_command('NOTICE', {
        session => $session,
        kernel  => $kernel,
        heap    => $heap,
    }, $args);

    return 1;
}

################################################################################

sub _format_from {
    my $self = shift;
    my $from = shift;

    my ($nick, $ident_and_host) = split /!/, $from;
    my ($ident, $host)          = split /@/, $ident_and_host;

    return {
        nick           => $nick,
        ident          => $ident,
        host           => $host,
        ident_and_host => $ident_and_host,
        orig           => $from,
    };
}

sub _format_message {
    my $self    = shift;
    my $message = shift;

    my @parts      = split / /, $message;
    my $is_command = $parts[0] =~ /^;/;
    my $command;

    if ($is_command) {
        $command = shift @parts;
        $command =~ s/^.//;
    }

    my @arguments        = @parts;
    my $arguments_string = join ' ', @arguments;

    return {
        original   => $message,
        is_command => $is_command,
        command    => $command && lc($command),
        arguments  => {
            str   => $arguments_string,
            split => \@arguments,
        },
    };
}

################################################################################

sub _build_events {
    return {
        irc_public => 1,
        irc_msg    => 1,
        irc_notice => 1,
    };
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Handler::External::Message - Metal's message events

=head1 DESCRIPTION

Maps message events to their modules.

=head2 METHODS

=over 4

=item C<irc_public()>

Message received in a channel.

=item C<irc_msg()>

Private message received.

=item C<irc_notice()>

Notice received.

=back

=head1 SEE ALSO

=over 4

=item C<Metal::Handler::Role::Module>

Map a command to a module.

=item C<Metal::Gateway>

=item C<Metal>

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

