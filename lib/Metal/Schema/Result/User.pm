package Metal::Schema::Result::User;

use Moose;
use MooseX::NonMoose;

use base 'DBIx::Class::Core';
extends  'DBIx::Class::Core';

################################################################################

__PACKAGE__->table('user');

__PACKAGE__->load_components(qw(
    +Metal::Schema::Helper::DateFields
));

__PACKAGE__->add_columns(
    id       => {
	data_type         => 'integer',
	extra             => { unsigned => 1 },
	is_auto_increment => 1,
	is_nullable       => 0,
    },
    hostmask => {
        data_type   => 'varchar',
        is_nullable => 0,
        size        => 100
    },
    name     => {
        data_type   => 'varchar',
        is_nullable => 0,
        size        => 45
    },
    lastfm   => {
        data_type   => 'varchar',
        is_nullable => 1,
        size        => 20,
    },
    ignored  => {
        data_type   => 'integer',
        size        => 0,
        default     => 0,
        is_nullable => 1,
    },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many('roles' => 'Metal::Schema::Result::UserRole', 'user_id');
__PACKAGE__->has_many('stats' => 'Metal::Schema::Result::UserStat', 'user_id');

################################################################################

around [ qw(add_role) ] => sub {
    my $orig = shift;
    my $self = shift;
    my $name = shift;

    my $role = $self->result_source->schema->resultset('Role')->search_rs({
        name => $name,
    })->first;

    return unless $role;
    return $self->$orig($role);
};

################################################################################

sub add_role {
    my $self = shift;
    my $role = shift;

    return $self->create_related('roles', { role_id => $role->id });
}

sub has_role {
    my $self = shift;
    my $name = shift;

    my $roles_rs = $self->roles;
    my $role;

    while (my $user_role = $roles_rs->next()) {
        if ($user_role->role->name eq $name) {
            $role = $user_role->role;

            last;
        }
    }

    return 0 unless $role;
    return $self->search_related('roles', { role_id => $role->id }) ? 1 : 0;
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;
__END__

=head1 NAME

Metal::Schema::Result::User

=head1 DESCRIPTION

Schema class for User objects.

=head2 METHODS

=over 4

=item C<add_role()>

Give the user access to a role.

=item C<has_role()>

Check if the user has access to a role.

=back

