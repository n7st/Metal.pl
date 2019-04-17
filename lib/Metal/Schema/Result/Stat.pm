package Metal::Schema::Result::Stat;

use strict;
use warnings;

use base 'DBIx::Class::Core';

################################################################################

__PACKAGE__->table('stat');

__PACKAGE__->load_components(qw(
    +Metal::Schema::Helper::ID
    +Metal::Schema::Helper::DateFields
));

__PACKAGE__->add_columns(
    'name',
    {
        data_type   => 'varchar',
        is_nullable => 0,
        size        => 50,
    },
);

__PACKAGE__->has_many(
    user_stats => 'Metal::Schema::Result::UserStat',
    { 'foreign.stat_id' => 'self.id' },
);

################################################################################

1;
__END__

=head1 NAME

Metal::Schema::Result::Stat

=head1 DESCRIPTION

Stats can be counted incrementally using C<Metal::Module::StatCounter>. They
are joined to C<Metal::Schema::Result::User> via C<Metal::Schema::Result::UserStat>.

In future, these could be used for counting channel statistics. This would
require "reserved" stat names which cannot be touched by the stat counting
module.

=head1 SEE ALSO

=over 4

=item * L<Metal::Schema::Result::UserStat>

=item * L<Metal::Schema::Result::User>

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

