package Metal::Handler::Pizza;

use Data::Printer;
use Moose;

extends 'Metal::Handler';

with qw/
    Metal::Roles::DB
    Metal::Roles::User
    Metal::Roles::Math
/;

################################################################################

around qw/add_new_pizza remove_last_pizza user_stats/ => sub {
    my $orig = shift;
    my $self = shift;

    return unless $self->args->{from}->{is_identified};

    my $user = $self->db->resultset('User')->from_host($self->args->{from});

    return $self->$orig(@_, $user);
};

################################################################################

sub add_new_pizza {
    my $self = shift;
    my $user = shift;

    my $output;

    my $pizza = $self->schema->resultset('Pizza')->create({
        user_id => $user->id,
    });

    if ($pizza) {
        $output = sprintf('New pizza added. (Your total: %d, overall: %d)',
            $self->_user_pizza_count($user),
            $self->_all_pizza_count(),
        );
    } else {
        $output = "I don't believe you can eat more than three pizzas in a day!";
    }

    return $output;
}

sub user_stats {
    my $self = shift;
    my $user = shift;

    my $user_score = $self->_user_pizza_count($user);
    my $all_score  = $self->_all_pizza_count();

    return sprintf("%s has eaten %d pizzas (All: %d | Percentage: %.2f%%)",
        $user->name,
        $user_score,
        $all_score,
        $self->percentage($user_score, $all_score),
    );
}

sub highscores {
    my $self = shift;

    my @rows;
    my $output = "The top pizza eaters are: ";
    my $limit  = $self->args->{list}->[0] // 5;

    $limit = 15 if $limit > 15;

    my $pizzas = $self->schema->resultset('Pizza')->search_rs({}, {
        '+select' => [{
            ''  => \'COUNT(`me`.`user_id`)',
            -as => 'appearances',
        }],
        group_by => qw/user_id/,
        rows     => $limit,
        order_by => 'appearances DESC',
    });

    my $i = 1;
    while (my $p = $pizzas->next()) {
        push @rows, sprintf('%d: %s (%d)',
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
        'pizzagods (Highscores list)',
        'pizzainfo (Show information about pizza counting)',
        'pizzahelp (Show this information)',
        'mypizzascore (Show your own score)',
    );

    $output .= join ', ', @rows;

    return $output;
}

sub info {
    my $self = shift;

    my $output = sprintf("There are %d pizzas in the database.",
        $self->_all_pizza_count(),
    );

    return $output;
}

sub legacy_count {
    return "Between 2015-04-28 and 2016-07-25, #metal ate 1552 pizzas.";
}

sub remove_last_pizza {
    my $self = shift;
    my $user = shift;

    my $output;

    my $pizza = $self->schema->resultset('Pizza')->search_rs({
        user_id => $user->id,
    }, {
        order_by => { -desc => 'me.id' }
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

