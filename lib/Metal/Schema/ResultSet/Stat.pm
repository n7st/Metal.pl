package Metal::Schema::ResultSet::Stat;

use strict;
use warnings;

use DateTime;

use base 'DBIx::Class::ResultSet';

################################################################################

sub increment {
    my $self = shift;
    my $args = shift;

    return unless $args->{user_id} && $args->{handle};

    my $schema = $self->result_source->schema;

    eval {
        $schema->txn_do(sub{
            # If any of this fails, the transaction is rolled back cleaning up
            # leftover data

            my $stat = $self->find_or_create({
                name => $args->{handle},
            });

            my $score = $stat->create_related('user_stats', {
                user_id => $args->{user_id},
            });
        });
    };

    return 'An error occurred adding your stat' if $@;

    my $stats = $self->search_rs({ name => $args->{handle} })->first->user_stats;

    return sprintf('New %s added (your total: %d, overall %d)',
        $args->{handle},
        $stats->search_rs({ user_id => $args->{user_id} })->count,
        $stats->count,
    );
}

sub decrement {
    my $self = shift;
    my $args = shift;

    return unless $args->{user_id} && $args->{handle};

    my $stat = $self->search_rs({ name => $args->{handle} })->first;

    return 'No such stat' unless $stat;

    my $user_stat = $stat->user_stats->search_rs({
        user_id => $args->{user_id},
    }, {
        order_by => { -desc => 'id' },
    })->first;

    return 'No entries found' unless $user_stat;

    $user_stat->delete();

    return 'Stat removed';
}

sub user_stat_today {
    my $self    = shift;
    my $handle  = shift;
    my $user_id = shift;

    my $dtf       = $self->result_source->schema->storage->datetime_parser;
    my $yesterday = DateTime->now->subtract(days => 1);
    my $stats     = $self->search_rs({ name => $handle })->first;

    return 0 unless $stats;

    my $for_user = $stats->user_stats;

    return $for_user->search_rs({
        user_id      => $user_id,
        date_created => { '>=' => $dtf->format_datetime($yesterday) }, 
    })->count();
}

################################################################################

1;
__END__

=head1 NAME

Metal::Schema::ResultSet::Stat

=head1 DESCRIPTION

=head2 METHODS

=over 4

=item C<increment()>

Add a new user stat value against a stat. Creates a new stat if one cannot be
found.

=item C<decrement()>

Remove the last user stat entry.

=item C<user_stat_today()>

Find the count user has added for a stat today.

=back

