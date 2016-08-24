package Metal::Roles::DB;

use Moose::Role;

use Metal::Schema;

################################################################################

has schema => (is => 'ro', isa => 'Metal::Schema', lazy_build => 1);

################################################################################

sub _build_schema {
    my $self = shift;

    return Metal::Schema->connect('dbi:mysql:Metal', 'root', 'root', {
        long_read_len     => 20480,
        mysql_enable_utf8 => 1,
    });
}

################################################################################

no Moose;
1;
__END__

