package Metal::Schema::Result::Channel;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('channel');

__PACKAGE__->load_components(qw/+Metal::Schema::Helper::DateFields/);

__PACKAGE__->add_columns(
    id => {
        data_type         => 'integer',
        extra             => { unsigned => 1 },
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    name => {
        data_type   => 'varchar',
        size        => '30',
        is_nullable => 0,
    },
    server_id => {
        data_type   => 'integer',
        extra       => { unsigned => 1 },
        is_nullable => 0,
    },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to("server" => 'Metal::Schema::Result::Server', {
    'foreign.id' => 'self.server_id',
});

1;
__END__

