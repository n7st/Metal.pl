package Metal::Schema;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

our $VERSION = 2.00;

__PACKAGE__->load_namespaces();
__PACKAGE__->stacktrace(1);

1;
__END__

=head1 NAME

Metal::Schema

=head1 DESCRIPTION

Base DB schema file. Not automatically generated; go nuts.

