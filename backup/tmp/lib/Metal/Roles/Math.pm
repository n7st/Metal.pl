package Metal::Roles::Math;

use Math::Round;
use Moose::Role;

################################################################################

sub percentage {
    my $self  = shift;
    my $num   = shift;
    my $total = shift;

    return nearest(.001, ($num * 100) / $total) || 0;
}

################################################################################

no Moose;
1;

