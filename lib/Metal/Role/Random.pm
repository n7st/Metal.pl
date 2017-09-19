package Metal::Role::Random;

use Moose::Role;

################################################################################

has maximum => (is => 'ro', isa => 'Int', default => 1000);

################################################################################

sub sometimes {
    my $self      = shift;
    my $threshold = shift;

    my $number = int(rand($self->maximum));

    return $number >= $threshold;
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Role::Random

=head1 DESCRIPTION

Random number generation and decision making.

=head2 METHODS

=over 4

=item C<sometimes()>

Check the random number is higher than the provided threshold.

=back

