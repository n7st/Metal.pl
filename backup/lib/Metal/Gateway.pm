package Metal::Gateway;

use Data::Printer;
use Moose;
use POE qw/
    Component::IRC
    Component::Cron
/;

with qw/
    Metal::Role::Config
    Metal::Role::Handler::Type
/;

################################################################################

has handlers => (is => 'ro', isa => 'HashRef', required => 1);

has package_states   => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);
has scheduled_events => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);

has schedule => (is => 'rw', isa => 'ArrayRef[POE::Component::Cron]');
has bots     => (is => 'rw', isa => 'ArrayRef[POE::Session]', default => sub { [] });

################################################################################

sub connect {
    my $self = shift;

    my $i = 0;

    foreach (@{$self->config->{connections}}) {
        my $bot     = POE::Component::IRC->spawn(%{$_->{for_poe}});
        my $session = POE::Session->create(
            package_states => $self->package_states,
            heap           => {
                id      => $i++,
                irc     => $bot,
                is_znc  => $_->{for_poe}->{Password} ? 1 : 0,
                present => $_->{join_channels}
            },
        );

        $self->_initialise_crontab($session->ID);

        push @{$self->bots}, $session;
    }

    return POE::Kernel->run();
}

################################################################################

sub _initialise_crontab {
    my $self       = shift;
    my $session_id = shift;

    my @schedule;

    foreach (@{$self->scheduled_events}) {
        # m h dom mon dow => POE::Session ID => some_task_event
        push @schedule, POE::Component::Cron->from_cron(
            $_->{cron} => $session_id => $_->{event}
        );
    }

    return $self->schedule(\@schedule);
}

################################################################################

sub _build_package_states {
    my $self = shift;

    my @states;

    foreach my $h (keys %{$self->handlers}) {
        push @states, $self->handlers->{$h} => [
            keys %{$self->handlers->{$h}->events},
        ];
    }

    return \@states;
}

sub _build_scheduled_events {
    my $self = shift;

    my @events;

    foreach my $h (keys %{$self->handlers}) {
        next unless $self->is_task_type($self->handlers->{$h}->type);

        # We're checking `-ne 1` because the values for Task events are calendar
        # strings (cronlike, * * * * *).
        my $events = $self->handlers->{$h}->events;
        my @cron   = grep { $events->{$_} ne 1 } keys %{$events};

        push @events, {
            event => $_,
            cron  => $events->{$_},
        } foreach @cron;
    }

    return \@events;
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Gateway

=head1 DESCRIPTION

POE::Component::IRC gateway mapping class. Handles connection to the network and
maps states to packages sent from the main Metal class.

=head2 METHODS

=over 4

=item C<connect()>

Spawns a bot, attaches it to a POE::Session with the packages states specified
from the main Metal class.

=item C<_initialise_crontab()>

Set up POE::Component::Cron tasks for every scheduled event.

=item C<_build_package_states()>

Map Handler classes to the events they contain in a POE::Component::IRC-friendly
way.

=item C<_build_scheduled_events()>

Map Handler classes to Task events they contain in a
POE::Component::Cron-friendly way.

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

