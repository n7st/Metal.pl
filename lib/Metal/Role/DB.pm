package Metal::Role::DB;

use Moose::Role;

use Metal::Schema;

with qw/
    Metal::Role::Config
    Metal::Role::Logger
/;

################################################################################

has schema => (is => 'ro', isa => 'Maybe[Metal::Schema]', lazy_build => 1);

################################################################################

sub _build_schema {
    my $self = shift;

    my $c = $self->config->{database};

    unless ($c) {
        $self->logger->warn("Schema role was included but we have no database connection information");

        return;
    }

    # For SQLite, username and password need to be blank strings
    $c->{username} //= '';
    $c->{password} //= '';

    return Metal::Schema->connect($c->{dsn}, $c->{username}, $c->{password}, {
        RaiseError => 1,
    });
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Role::DB

=head1 DESCRIPTION

Access Metal's database.

=head2 USAGE

    use Moose;

    with 'Metal::Role::DB';

    sub something {
        my $self = shift;

        my $items = $self->schema->resultset('Some::Result::Class')->all();

        return;
    }

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

