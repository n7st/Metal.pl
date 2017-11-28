package Metal::Module::Core::UserManagement;

use Moose;

extends 'Metal::Module';
with    qw(
    Metal::Module::Role::WithCommands
    Metal::Role::UserOrArg
);

with 'Metal::Module::Role::AdminOnly' => {
    subs => [ '_ignore', '_unignore' ],
};

################################################################################

around [ qw(_ignore _unignore) ] => sub {
    my $orig = shift;
    my $self = shift;
    my $args = shift;

    my $ignore = $args->{message_args}->[0];
    my @users  = $self->bot->db->resultset('User')->search_rs({
        'LOWER(me.name)' => lc($ignore),
    })->all();

    return $self->$orig($args, \@users, $ignore);
};

################################################################################

sub _ignore {
    my $self   = shift;
    my $args   = shift;
    my $users  = shift;
    my $ignore = shift;

    my $ignored_count = 0;

    foreach my $user (@{$users}) {
        next if $user->has_role('Admin');

        $user->ignored(1);
        $user->update();
        $ignored_count++;
    }

    if (scalar @{$users} > 0) {
        return sprintf("Ignored %d users matching %s",
            $ignored_count, $ignore);
    } else {
        return "No users matched ${ignore}";
    }
}

sub _unignore {
    my $self   = shift;
    my $args   = shift;
    my $users  = shift;
    my $ignore = shift;

    foreach my $user (@{$users}) {
        $user->ignored(0);
        $user->update();
    }

    if (scalar @{$users} > 0) {
        return sprintf("Unignored %d users matching ${ignore}",
            scalar @{$users}, $ignore);
    } else {
        return "No users matched ${ignore}";
    }
}

################################################################################

sub _build_commands {
    return {
        ignore   => '_ignore',
        unignore => '_unignore',
    };
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;
__END__

=head1 NAME

Metal::Module::Core::UserManagement - User related operations

=head1 DESCRIPTION

Bot commands for managing users. Commands in this class are wrapped with the
C<Metal::Module::Role::AdminOnly> role which locks use to administrators only.

=head2 TODO

=over 4

=item CREATE MISSING USERS

Currently, only users already in the database may be ignored. Instead,
C<find_or_create()> should be used. This will probably require WHOIS response
information for the user (which may be better in a common location).

=back

=head2 METHODS

=over 4

=item C<_ignore()>

Ignore a given list of users.

=item C<_unignore()>

Unignore a given list of users.

=back

=head2 ATTRIBUTES

=over 4

=item C<commands>

Commands provided by this class.

=back

