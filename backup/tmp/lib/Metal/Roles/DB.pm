package Metal::Roles::DB;

use Moose::Role;

use Metal::Schema;

with 'Metal::Roles::Config';

################################################################################

has schema => (is => 'ro', isa => 'Metal::Schema', lazy_build => 1);

################################################################################

sub db { shift->schema; }

################################################################################

sub _build_schema {
    my $self = shift;

    my $c = $self->config->{database};

    return Metal::Schema->connect($c->{host}, $c->{user}, $c->{password}, {
        long_read_len     => 20480,
        mysql_enable_utf8 => 1,
    });
}

################################################################################

no Moose;
1;
__END__

