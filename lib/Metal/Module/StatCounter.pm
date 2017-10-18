package Metal::Module::StatCounter;

use Moose;

extends 'Metal::Module';
with    'Metal::Role::UserOrArg';

################################################################################

has default_max_stat_per_day => (is => 'ro', isa => 'Int', default => 3);

has commands         => (is => 'ro', isa => 'ArrayRef',   lazy_build => 1);
has graph_url        => (is => 'ro', isa => 'Maybe[Str]', lazy_build => 1);
has max_stat_per_day => (is => 'ro', isa => 'Int',        lazy_build => 1);

around [ qw(_increment _decrement) ] => sub {
    my $orig   = shift;
    my $self   = shift;
    my $args   = shift;
    my $handle = shift;

    my $user = $self->user_or_arg($args, { skip_args => 1 });

    return $self->$orig($handle, $user->id);
};

around [ qw(_stats) ] => sub {
    my $orig   = shift;
    my $self   = shift;
    my $args   = shift;
    my $handle = shift;

    my $user = $self->user_or_arg($args);

    unless ($user) {
        return 'No stats found.';
    }

    return $self->$orig($handle, $user);
};

################################################################################

sub on_bot_public {
    my $self  = shift;
    my $event = shift;

    my ($handle, $output);

    foreach my $command (@{$self->commands}) {
        if (($handle) = $event->{args}->{$command->{location}} =~ $command->{regex}) {
            my $method = $command->{method};

            $output = $self->$method($event->{args}, $handle);
        }
    }

    $self->bot->message_channel($event->{args}->{channel}, $output);

    return 1;
}

################################################################################

sub _increment {
    my $self    = shift;
    my $handle  = shift;
    my $user_id = shift;

    my $count_today = $self->bot->db->resultset('Stat')->user_stat_today($handle, $user_id);

    if ($count_today >= $self->max_stat_per_day) {
        return sprintf('You may only add %s %ss per day.', $self->max_stat_per_day, $handle);
    }

    my $output = $self->bot->db->resultset('Stat')->increment({
        handle  => $handle,
        user_id => $user_id,
    });

    return $output;
}

sub _decrement {
    my $self    = shift;
    my $handle  = shift;
    my $user_id = shift;

    return $self->bot->db->resultset('Stat')->decrement({
        handle  => $handle,
        user_id => $user_id,
    });
}

sub _stats {
    my $self   = shift;
    my $handle = shift;
    my $user   = shift;

    my $count = $user->stats_rs->search_rs({
        'stat.name' => $handle,
    }, {
        prefetch => [ 'stat' ],
    })->all();

    return sprintf('%s count for %s: %d', $handle, $user->name, $count);
}

sub _highscores {
    my $self   = shift;
    my $args   = shift;
    my $handle = shift;

    my $highscores = $self->bot->db->resultset('UserStat')->highscores($handle, 6);

    return "There are no highscores for ${handle}" unless @{$highscores};

    my $user_scores = join(', ', map { sprintf('%s: %s', $_->{name}, $_->{score}) } @{$highscores});
    my $graph_desc  = $self->graph_url ? 'Graphs: '.$self->graph_url : '';

    return sprintf('%s highscores: %s%s', $handle, $user_scores, $graph_desc);
}

################################################################################

sub _build_commands {
    # method:   the subroutine in this class to run
    # location: where we're doing the regex match (i.e. in the message or
    #           command)
    # regex:    the match we're looking for

    return [{
        method   => '_increment',
        location => 'message',
        regex    => qr/^(\w+)\+\+$/,
    }, {
        method   => '_decrement',
        location => 'message',
        regex    => qr/^(\w+)\-\-$/,
    }, {
        method   => '_stats',
        location => 'command',
        regex    => qr/^(\w+)stats$/,
    }, {
        method   => '_highscores',
        location => 'command',
        regex    => qr/^(\w+)highscores$/,
    }, {
        method   => '_highscores',
        location => 'command',
        regex    => qr/^(\w+)gods$/,
    }];
}

sub _build_graph_url {
    my $self = shift;

    return $self->bot->config->{stats}->{graph_url};
}

sub _build_max_stat_per_day {
    my $self = shift;

    return $self->bot->config->{stats}->{max_per_day} || $self->default_max_stat_per_day;
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;
__END__

=head1 NAME

Metal::Module::StatCounter

