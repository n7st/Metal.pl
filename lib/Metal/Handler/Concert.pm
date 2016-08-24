package Metal::Handler::Concert;

use Data::Printer;
use Moose;

extends 'Metal::Input';

with qw/
    Metal::Roles::DB
    Metal::Roles::User
/;

################################################################################

sub add_band {
    my $self = shift;

    # TODO figure out a way to split the arguments from IRC

    unless ($self->is_identified($self->args->{from}->{hostmask})) {
        return "You are not an identified user.";
    }

    my $user = $self->user_from_host(
        $self->args->{from}->{hostmask},
        $self->args->{from}->{nick}
    );

    my $band = $self->_band_from_name($self->args->{band}, $user);

    my $was_seen = $self->schema->resultset('UserBand')->create({
        band_id     => $band->id,
        description => $self->args->{description} // '',
        user_id     => $user->id,
    });

    return sprintf(
        "Added entry for %s against %s",
        $band->name,
        $user->name,
    );
}

sub add_festival {
    my $self = shift;

    unless ($self->args->{from}->{is_identified}) {
        return "You are not an identified user.";
    }

    my $user = $self->user_from_host(
        $self->args->{from}->{hostmask},
        $self->args->{from}->{nick}
    );
    my $festival = $self->_festival_from_name($self->args->{festival}, $self->args->{date}, $user);

    my $was_at_festival = $self->schema->resultset('UserFestival')->create({
        festival_id => $festival->id,
        user_id     => $user->id,
    });

    return sprintf(
        "Added entry for %s against %s",
        $festival->name,
        $user->name,
    );
}

sub band_info {
    my $self = shift;

    my $band = $self->schema->resultset('Band')->find({
        name => $self->args->{band},
    });

    unless ($band) {
        return sprintf("No one has seen %s", $self->args->{band});
    }

    my $seen_by = $self->schema->resultset('UserBand')->search_rs({
        band_id => $band->id,
    });

    my @users;

    while (my $b = $seen_by->next()) {
        push @users, $b->user->name;
    }

    return sprintf(
        "%s has been seen by %s.",
        $band->name,
        join ', ', @users,
    );
}

sub help {
    my $self = shift;
}

sub highscores {
    my $self = shift;
}

################################################################################

sub _band_from_name {
    my $self = shift;
    my $name = shift;
    my $user = shift;

    my $band = $self->schema->resultset('Band')->find_or_new({
        name => $name,
    });

    unless ($band->in_storage()) {
        $band->created_by($user->id);
        $band->modified_by($user->id);
        $band->insert();
    }

    return $band;
}

sub _festival_from_name {
    my $self = shift;
    my $name = shift;
    my $date = shift;
    my $user = shift;

    my $festival = $self->schema->resultset('Festival')->find_or_new({
        name => $name,
    });

    unless ($festival->in_storage()) {
        $festival->created_by($user->id);
        $festival->modified_by($user->id);
        $festival->date($date); # TODO format
        $festival->insert();
    }

    return $festival;
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Handler::Concert

=head1 DESCRIPTION

Controller to convert user input into concert information in the database.

