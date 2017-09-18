package Metal::Role::Maths;

use Math::Round;
use Moose::Role;

################################################################################

sub percentage {
    my $self  = shift;
    my $num   = shift;
    my $total = shift;

    return 0 unless $num && $total;

    return nearest(.001, ($num * 100) / $total) || 0;
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Role::Maths

=head1 DESCRIPTION

Common mathematic functions.

=head2 METHODS

=over 4

=item C<percentage()>

Get a percentage of a number.

=back

