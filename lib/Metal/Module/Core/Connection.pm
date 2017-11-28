package Metal::Module::Core::Connection;

use Moose;

extends 'Metal::Module';
with    qw(
    Metal::Role::UserOrArg
    Metal::Module::Role::WithCommands
);

################################################################################

around [ qw(_disconnect _reconnect) ] => sub {
    my $orig = shift;
    my $self = shift;
    my $args = shift;

    my $current_user = $self->user_or_arg($args, { skip_args => 1 });

    unless ($current_user->has_role('Admin')) {
        return;
    }

    return $self->$orig($args);
};

################################################################################

sub _disconnect {
    my $self = shift;
    my $args = shift;

    return $self->bot->yield(quit => 'Disconnecting');
}

sub _reconnect {
    my $self = shift;
    my $args = shift;

    return $self->bot->yield('connect');
}

################################################################################

sub _build_commands {
    return {
        disconnect => '_disconnect',
        reconnect  => '_reconnect',
    };
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;
__END__

=head1 NAME

Metal::Module::Core::Connection

=head1 DESCRIPTION

Commands for handling the bot's IRC connections.

=head2 ATTRIBUTES

=over 4

=item C<commands>

Map of command to method.

=back

=head2 METHODS

=over 4

=item C<on_bot_public()>

Runs on every public message to the channel.

=item C<_disconnect()>

Disconnects the bot from the IRC network. This and C<_reconnect()> are wrapped
to ensure the current user is a bot admin.

=item C<_reconnect()>

Reconnects the bot to the IRC network (jump).

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

