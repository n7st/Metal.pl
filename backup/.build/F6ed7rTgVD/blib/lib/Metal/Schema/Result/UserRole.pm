package Metal::Schema::Result::UserRole;

use strict;
use warnings;

use base 'DBIx::Class::Core';

################################################################################

__PACKAGE__->table('user_role');

__PACKAGE__->load_components(qw(
    +Metal::Schema::Helper::DateFields
));

__PACKAGE__->add_columns(
    id      => {
	data_type         => 'integer',
	extra             => { unsigned => 1 },
	is_auto_increment => 1,
	is_nullable       => 0,
    },
    user_id => {
	data_type         => 'integer',
	extra             => { unsigned => 1 },
	is_nullable       => 0,
    },
    role_id => {
	data_type         => 'integer',
	extra             => { unsigned => 1 },
	is_nullable       => 0,
    }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(user => 'Metal::Schema::Result::User', 'user_id');
__PACKAGE__->belongs_to(role => 'Metal::Schema::Result::Role', 'role_id');

################################################################################

1;

