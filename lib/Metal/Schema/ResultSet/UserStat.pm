package Metal::Schema::ResultSet::UserStat;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

################################################################################

sub highscores {
    my $self   = shift;
    my $handle = shift;
    my $limit  = shift;

    my $filters = {
        prefetch  => [ 'stat', 'user' ],
        '+select' => {
            ''  => \'COUNT(me.user_id)',
            -as => 'appearances',
        },
        group_by  => [ 'stat.name', 'me.user_id' ],
        order_by  => 'appearances DESC',
    };

    $filters->{rows} = $limit if $limit;

    my @stats = $self->search_rs({
        'stat.name' => $handle,
    }, $filters)->all();

    return [ map {
        {
            score => $_->get_column('appearances'),
            name  => $_->user->name,
        }
    } @stats ];
}

################################################################################

1;
__END__

=head1 NAME

Metal::Schema::ResultSet::UserStat

=head1 DESCRIPTION

ResultSet methods for UserStats.

=head2 METHODS

=over 4

=item C<highscores()>

Get a highscores list for a given Stat name.

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

