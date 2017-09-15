package Metal::Module::StatCounter;

use DDP;
use Moose;

extends 'Metal::Module';
with    'Metal::Role::UserOrArg';

################################################################################

has default_max_stat_per_day => (is => 'ro', isa => 'Int', default => 3);

has max_stat_per_day => (is => 'ro', isa => 'Int', lazy_build => 1);

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

    if (($handle) = $event->{args}->{message} =~ /^(\w+)\+\+$/) {
        $output = $self->_increment($event->{args}, $handle);
    } elsif (($handle) = $event->{args}->{message} =~ /^(\w+)\-\-$/) {
        $output = $self->_decrement($event->{args}, $handle);
    } elsif (($handle) = $event->{args}->{command} =~ /^(\w+)stats$/) {
        $output = $self->_stats($event->{args}, $handle);
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
    })->all;

    return sprintf('%s count for %s: %d', $handle, $user->name, $count);
}

################################################################################

sub _build_max_stat_per_day {
    my $self = shift;

    return $self->default_max_stat_per_day;
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;
__END__

=head1 NAME

Metal::Module::StatCounter

