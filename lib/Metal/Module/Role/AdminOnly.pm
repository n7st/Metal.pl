package Metal::Module::Role::AdminOnly;

use MooseX::Role::Parameterized;

parameter subs => (is => 'ro', isa => 'ArrayRef', required => 1);

requires 'bot';

################################################################################

role {
    my $self = shift;

    around $self->subs => sub {
        my $orig  = shift;
        my $class = shift;
        my $args  = shift;

        return unless $args;
        return unless $class->bot;

        my $user = $class->bot->db->resultset('User')->from_hostmask({
            hostmask => $args->{hostmask},
            nickname => $args->{nickname},
        });

        return unless $user->has_role('Admin');
        return $class->$orig($args, @_); # Finally, the user has permission
    };
};

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Module::Role::AdminOnly - Lock commands to administrative users

=head1 DESCRIPTION

Lock a list of commands (in the "subs" parameter) so only users with the Admin
role can use them.

=head2 USAGE

The role can be consumed as below. The HashRef contains the parameters to be
passed to the role.

    use Moose;

    with 'Metal::Module::Role::AdminOnly' => {
        subs => [ '_ignore', '_unignore' ],
    };

=head2 PARAMETERS

=over 4

=item C<subs>

A list of subroutines in the class which consumes this role which may only be
used by administrators.

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

