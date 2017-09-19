package Metal::Role::Logger;

use Log::Log4perl qw(:easy);
use Log::Log4perl::Level;
use Moose::Role;

################################################################################

has logger => (is => 'ro', isa => 'Log::Log4perl::Logger', lazy_build => 1);

################################################################################

sub _build_logger {
    my $self = shift;

    Log::Log4perl->easy_init($DEBUG);

    return Log::Log4perl->get_logger();
}

################################################################################

no Moose;
1;

