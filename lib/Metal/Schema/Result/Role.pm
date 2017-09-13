package Metal::Schema::Result::Role;

use strict;
use warnings;

use base 'DBIx::Class::Core';

################################################################################

__PACKAGE__->table('role');

__PACKAGE__->load_components(qw(
    +Metal::Schema::Helper::DateFields
));

__PACKAGE__->add_columns(
    id   => {
	data_type         => 'integer',
	extra             => { unsigned => 1 },
	is_auto_increment => 1,
	is_nullable       => 0,
    },
    name => {
        data_type   => 'varchar',
        is_nullable => 0,
        size        => 50
    },
);

__PACKAGE__->set_primary_key('id');

################################################################################

1;

