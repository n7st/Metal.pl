package Metal::Handler;

use Moose;

################################################################################

has args => (is => 'ro', isa => 'HashRef', default => sub { {}; });

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Handler

=head1 DESCRIPTION

Base class for all user-input-centric bot modules containing common methods and
attributes.

=head1 AUTHOR

Mike Jones <mike@netsplit.org.uk>

