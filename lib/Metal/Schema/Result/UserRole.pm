package Metal::Schema::Result::UserRole;

use strict;
use warnings;

use base 'DBIx::Class::Core';

################################################################################

__PACKAGE__->table('user_role');

__PACKAGE__->load_components(qw(
    +Metal::Schema::Helper::ID
    +Metal::Schema::Helper::DateFields
    +Metal::Schema::Helper::BelongingToUser
));

__PACKAGE__->add_columns(
    'role_id',
    {
        data_type   => 'integer',
        extra       => { unsigned => 1 },
        is_nullable => 0,
    },
);

__PACKAGE__->belongs_to(
    role => 'Metal::Schema::Result::Role',
    { 'foreign.id' => 'self.role_id' },
);

################################################################################

1;
__END__

=head1 NAME

Metal::Schema::Result::UserRole

=head1 DESCRIPTION

Join table between L<Metal::Schema::Result::Role> and L<Metal::Schema::Result::User>.

=head1 SEE ALSO

=over 4

=item * L<Metal::Schema::Result::Role>

=item * L<Metal::Schema::Result::User>

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

