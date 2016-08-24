package Metal::Schema::ResultSet::Pizza;

use strict;
use warnings;

use DateTime;
use Data::Printer;

use base 'DBIx::Class::ResultSet';

sub user_pizzas_today {
    my $self    = shift;
    my $user_id = shift;

    my $dtf       = $self->result_source->schema->storage->datetime_parser;
    my $yesterday = DateTime->now->subtract(days => 1);
    my $today     = DateTime->now();

    return $self->search_rs({
        date_created => {
            -between => [
                $dtf->format_datetime($yesterday),
                $dtf->format_datetime($today),
            ]
        },
        user_id      => $user_id,
    })->count();
}

1;
__END__

