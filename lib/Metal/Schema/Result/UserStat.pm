package Metal::Schema::Result::UserStat;

use strict;
use warnings;

use base 'DBIx::Class::Core';

################################################################################

__PACKAGE__->table('user_stat');

__PACKAGE__->load_components(qw(
    +Metal::Schema::Helper::ID
    +Metal::Schema::Helper::DateFields
    +Metal::Schema::Helper::BelongingToUser
));

__PACKAGE__->add_columns(
    'stat_id',
    {
        data_type   => 'integer',
        extra       => { unsigned => 1 },
        is_nullable => 0,
    },
);

__PACKAGE__->belongs_to(
    stat => 'Metal::Schema::Result::Stat',
    { 'foreign.id' => 'self.stat_id' },
);

################################################################################

1;
__END__

=head1 NAME

Metal::Schema::Result::UserStat

=head1 DESCRIPTION

Join table between L<Metal::Schema::Result::Stat> and L<Metal::Schema::Result::User>.

=head1 SEE ALSO

=over 4

=item * L<Metal::Schema::Result::Stat>

=item * L<Metal::Schema::Result::User>

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

