package Metal::Module::Role::WithCommands;

use Moose::Role;

requires 'bot';

################################################################################

has commands => (is => 'ro', isa => 'HashRef', lazy_build => 1);

################################################################################

sub on_bot_public {
    my $self  = shift;
    my $event = shift;

    my $output = $self->_attempt_command($event->{args});

    $self->bot->message_channel($event->{args}->{channel}, $output);

    return 1;
}

################################################################################

sub _attempt_command {
    my $self   = shift;
    my $args   = shift;
    my $handle = shift || 'commands';

    return unless $self->$handle;

    my $command = $args->{command};

    return unless $command;

    if (my $method = $self->{$handle}->{$command}) {
        return $self->$method($args);
    }   

    return;
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Module::Role::WithCommands - Add commands to a handler class.

=head1 DESCRIPTION

Items in the C<commands> attribute map a "command" to a subroutine which should
be run in the class which consumes this role.

=head2 METHODS

=over 4

=item C<on_bot_public()>

Runs on every public message sent to channels the bot is in.

=item C<_attempt_command()>

Attempt to run a command from the C<commands> attribute. If it exists, the
subroutine it references will run, otherwise nothing happens.

=back

=head2 ATTRIBUTES

=over 4

=item C<commands>

Must be lazily built from the consuming class.

    sub _build_commands {
        return {
            # command             # method
            some_command       => '_the_subroutine_it_should_run',
            some_other_command => '_another_subroutine',
        };
    }

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

