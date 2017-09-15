package Metal::Role::UserOrArg;

use Moose::Role;

requires 'bot';

################################################################################

sub user_or_arg {
    my $self  = shift;
    my $args  = shift;
    my $extra = shift // {};

    # If skip_args is provided, we're expecting to retrieve from the database
    if ($args->{message_args}->[0] && !$extra->{skip_args}) {
        # Return the first user we can find with the provided nickname. Not
        # 100% accurate (e.g. if someone changes their hostmask.
        return $self->bot->db->resultset('User')->search_rs({
            name => $args->{message_args}->[0],
        })->first;
    }

    # Find or create a user
    return $self->bot->db->resultset('User')->from_hostmask({
        hostmask => $args->{hostmask},
        nickname => $args->{nickname},
    });
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Role::UserOrArg

=head1 DESCRIPTION

Parse message arguments for a username string or find a user from the database.

=head2 ATTRIBUTES

=item C<bot>

C<bot> must be implemented B<first> in your class (i.e. consume this role below
C<bot> being initialised.

    extends 'Metal::Module';          # First, initialises bot
    with    'Metal::Role::UserOrArg'; # Second

=head2 METHODS

=over 4

=item C<user_or_arg()>

Returns either a username from the message input, or finds/creates a user in the
bot's database.

=back

