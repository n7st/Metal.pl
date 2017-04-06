package Metal::Schema;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

our $VERSION = 1;

__PACKAGE__->load_namespaces();

1;
__END__

=head1 NAME

Metal::Schema - Base class for the bot's database.

=head1 DESCRIPTION

Base class for the bot's database.

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

