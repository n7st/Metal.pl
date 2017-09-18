package Metal::Module::IntervalExample;

use Moose;
use Reflex::Interval;
use Reflex::Trait::Watched qw(watches);

extends 'Metal::Module';
with    'Metal::Role::Logger';

################################################################################

watches ticker => (is => 'rw', isa => 'Reflex::Interval', setup => { interval => 60, auto_repeat => 1 });

################################################################################

sub on_ticker_tick {
    my $self = shift;

    $self->logger->debug('Tick from Metal::Module::IntervalExample');

    return 1;
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;
__END__

=head1 NAME

Metal::Module::IntervalExample

=head1 DESCRIPTION

An example module showing how to run a job every n seconds (in this case every
60 seconds).

=head2 METHODS

=over 4

=item C<on_ticker_tick()>

Runs every time C<ticker> ticks, so in this case every 60 seconds.

=back

=head1 LIMITATIONS

Making the interval too small appears to cause lag to other bot functionality.

=head1 SEE ALSO

=over 4

=item C<Reflex::Role::Interval>

http://search.cpan.org/~rcaputo/Reflex-0.100/lib/Reflex/Role/Interval.pm

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

