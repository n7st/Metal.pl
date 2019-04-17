package Metal::Schema::Result::Role;

use strict;
use warnings;

use base 'DBIx::Class::Core';

################################################################################

__PACKAGE__->table('role');

__PACKAGE__->load_components(qw(
    +Metal::Schema::Helper::ID
    +Metal::Schema::Helper::DateFields
));

__PACKAGE__->add_columns(
    'name',
    {
        data_type   => 'varchar',
        is_nullable => 0,
        size        => 50
    },
);

################################################################################

1;
__END__

=head1 NAME

Metal::Schema::Result::Role

=head1 DESCRIPTION

Roles are used for managing user permissions to certain aspects of the bot (for
example, only users with the "Admin" role may ignore and unignore users).

They are joined to the user object via L<Metal::Schema::Result::UserRole> which
is accessible through the C<roles> relationship on L<Metal::Schema::Result::User>.

=head1 SEE ALSO

=over 4

=item * L<Metal::Schema::Result::UserRole>

=item * L<Metal::Schema::Result::User>

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

