package Metal::Schema::Result::Server;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('server');

__PACKAGE__->load_components(qw/+Metal::Schema::Helper::DateFields/);

__PACKAGE__->add_columns(
    id        => {
        data_type         => 'integer',
        extra             => { unsigned => 1 },
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    hostname  => {
        data_type   => 'varchar',
        is_nullable => 0,
        size        => 50,
    },
    port      => {
        data_type   => 'varchar',
        is_nullable => 0,
        size        => 6,
    },
    connect   => {
        data_type => 'integer',
        size      => 1,
    },
    join_chan => {
        data_type => 'integer',
        size      => 1,
    },
    debug     => {
        data_type => 'integer',
        size      => 1,
    },
    ssl       => {
        data_type => 'integer',
        size      => 1,
    },
    nickname  => {
        data_type   => 'varchar',
        is_nullable => 1, # will just be set to nonsense by the IRCd
        size        => 9,
    },
    ident     => {
        data_type   => 'varchar',
        is_nullable => 0,
        size        => 11,
    },
);

__PACKAGE__->set_primary_key('id');

1;
__END__

=head1 NAME

Metal::Schema::Result::Server

=head1 DESCRIPTION

Schema class for Server result objects from the database.

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

