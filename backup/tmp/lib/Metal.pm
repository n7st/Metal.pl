package Metal;

# ABSTRACT: old version

use Data::Printer;
use HTTP::Status;
use Moose;

use Metal::Input;

with qw/
    Metal::Roles::DB
    Metal::Roles::Config
/;

################################################################################

has input => (is => 'ro', isa => 'Metal::Input', lazy_build => 1);

################################################################################

sub _build_input { Metal::Input->new(); }

################################################################################

no Moose;
1;
__END__

