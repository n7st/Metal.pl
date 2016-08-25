package Metal::Handler::Concert;

use Data::Printer;
use Getopt::Long qw/GetOptionsFromString/;
use List::MoreUtils qw/uniq/;
use Moose;

extends 'Metal::Input';

with qw/
    Metal::Roles::DB
    Metal::Roles::User
/;

################################################################################

sub add_band {
    my $self = shift;

    unless ($self->args->{from}->{is_identified}) {
        return "You are not an identified user.";
    }

    my $input = join ' ', @{$self->args->{list}};
    my ($extra_info, $band_name);

    GetOptionsFromString(
        $input,
        'i|info=s' => \$extra_info,
        'n|name=s' => \$band_name,
    );

    return 'Usage: ;addband -n "Band Name" (-i "Extra Info Here")' unless $band_name;

    my $user = $self->user_from_host($self->args->{from});

    my $band = $self->_band_from_name($band_name, $user);

    my $was_seen = $self->schema->resultset('UserBand')->create({
        band_id     => $band->id,
        description => $extra_info // '',
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

    my $input = join ' ', @{$self->args->{list}};
    my ($festival_name, $festival_date);

    GetOptionsFromString(
        $input,
        'n|name=s' => \$festival_name,
        'd|date=s' => \$festival_date,
    );

    return 'Usage: ;addfestival -n "Festival Name" -d "2016-12-31"' unless $festival_name;

    my $user = $self->user_from_host($self->args->{from});

    my $festival = $self->_festival_from_name($festival_name, $festival_date, $user);

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

    return unless $self->args->{list}->[0];

    my $band_name = join ' ', @{$self->args->{list}};
    my $band      = $self->schema->resultset('Band')->find({
        name => $band_name,
    });

    unless ($band) {
        return sprintf("No one has seen %s", $band_name);
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
        join ', ', uniq @users,
    );
}

sub user_band_total {
    my $self = shift;

    my $user;

    p $self->args;

    if ($self->args->{list}->[0]) {
        $user = $self->schema->resultset('User')->find({
            name => $self->args->{list}->[0]
        });
    } elsif ($self->args->{from}->{is_identified}) {
        $user = $self->user_from_host($self->{args}->{from});
    } else {
        return "You need to be an identified user to request your own stats.";
    }

    my $count = $self->schema->resultset('UserBand')->search_rs({
        user_id => $user->id,
    }, {
        group_by => 'me.band_id',
    });

    my $total = $self->schema->resultset('UserBand')->search_rs({
        user_id => $user->id,
    });

    return sprintf(
        "%s has seen %s shows (%s individual bands)",
        $user->name,
        $total,
        $count,
    );
}

sub help {
    my $self = shift;

    my $output = "Available commands: ";
    my @rows   = (
        'addband (add a band to your concerts list)',
        'addfestival (add a festival to your concerts list)',
        'bandinfo (see who has seen a band',
        'concerthelp (display this information',
        'usershows (display total shows for a person)',
    );

    $output .= join ', ', @rows;

    return $output;
}

sub highscores {
    my $self = shift;

    my @rows;
    my $output = "The people who've seen the most individual shows are: ";
    my $shows  = $self->schema->resultset('UserBand')->search_rs({}, {
        '+select' => [{
            ''  => \'COUNT(`me`.`user_id`)',
            -as => 'appearances',
        }],
        group_by  => qw/user_id/,
        rows      => 5,
        order_by => 'appearances DESC',
    });

    my $i = 1;
    while (my $hs = $shows->next()) {
        push @rows, sprintf(
            '%d: %s (%d)',
            $i,
            $hs->user->name,
            $hs->{_column_data}->{appearances},
        );

        $i++;
    }

    $output .= join ', ', @rows;

    return $output;
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

