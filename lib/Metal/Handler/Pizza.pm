package Metal::Handler::Pizza;

use Data::Printer;
use Moose;

extends 'Metal::Handler';

with 'Metal::Roles::DB';

################################################################################

sub add_new_pizza {
    my $self = shift;

    my $user = $self->_user_for_hostmask($self->args->{hostmask}, $self->args->{nick});
    my $output;

    my $pizza = $self->schema->resultset('Pizza')->create({
        user_id => $user->id,
    });

    if ($pizza) {
        $output = sprintf(
            'New pizza added. (Your total: %d, overall: %d)',
            $self->_user_pizza_count($user),
            $self->_all_pizza_count(),
        );
    } else {
        $output = "I don't believe you can eat more than three pizzas in a day!";
    }

    return $output;
}

sub highscores {
    my $self = shift;

    my $output = "The top pizza eaters are: ";
    my @rows;

    my $pizzas = $self->schema->resultset('Pizza')->search_rs({}, {
        '+select' => [{
            ''  => \'COUNT(`me`.`user_id`)',
            -as => 'appearances',
        }],
        group_by => qw/user_id/,
        rows     => 5,
        order_by => 'appearances DESC',
    });

    my $i = 1;
    while (my $p = $pizzas->next()) {
        push @rows, sprintf(
            '%d: %s (%d)',
            $i,
            $p->user->name,
            $p->{_column_data}->{appearances}
        );

        $i++;
    }

    $output .= join ', ', @rows;

    return $output;
}

sub help {
    my $self = shift;

    my $output = "Available commands: ";

    my @rows = (
        'pizza++ (Add a new pizza)',
        'pizza-- (Remove your last pizza)',
        'pizzahighscores (Highscores list)',
        'pizzainfo (Show information about pizza counting)',
        'pizzahelp (Show this information)',
    );

    $output .= join ', ', @rows;

    return $output;
}

sub info {
    my $self = shift;

    my $output = sprintf(
        "There are %d pizzas in the database.",
        $self->_all_pizza_count(),
    );

    return $output;
}

sub remove_last_pizza {
    my $self = shift;

    my $user = $self->_user_for_hostmask($self->args->{hostmask}, $self->args->{nick});
    my $output;

    my $pizza = $self->schema->resultset('Pizza')->search_rs({
        user_id => $user->id,
    }, {
        order_by => {
            -desc => 'me.id',
        }
    })->first();

    if ($pizza) {
        $pizza->delete();

        $output = "I've removed your last pizza from the database.";
    } else {
        $output = "You don't have any pizzas in the database.";
    }

    return $output;
}

################################################################################

sub _all_pizza_count { shift->schema->resultset('Pizza')->count(); }

sub _user_pizza_count {
    my $self = shift;
    my $user = shift;

    return $self->schema->resultset('Pizza')->search_rs({
        user_id => $user->id
    })->count();
}

sub _user_for_hostmask {
    my $self     = shift;
    my $hostmask = shift;
    my $nick     = shift;

    my $user = $self->schema->resultset('User')->find_or_new({
        hostmask => $hostmask
    });

    unless ($user->in_storage()) {
        $user->name($nick);
        $user->insert();
    }

    return $user;
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Handler::Pizza

=head1 DESCRIPTION

Controller for converting user commands into pizza-related database operations.

=head1 AUTHOR

Mike Jones <mike@netsplit.org.uk>

