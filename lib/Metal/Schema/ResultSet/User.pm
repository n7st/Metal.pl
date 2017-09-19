package Metal::Schema::ResultSet::User;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

################################################################################

sub from_hostmask {
    my $self = shift;
    my $args = shift;

    return unless $args->{hostmask};

    my $user = $self->find_or_new({ hostmask => $args->{hostmask} });

    unless ($user->in_storage) {
        $user->name($args->{nickname});
        $user->insert();
    }

    return $user;
}

################################################################################

1;

