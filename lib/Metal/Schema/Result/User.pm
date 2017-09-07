package Metal::Schema::Result::User;

use strict;
use warnings;

use base 'DBIx::Class::Core';

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
);

__PACKAGE__->set_primary_key('id');

################################################################################

1;

