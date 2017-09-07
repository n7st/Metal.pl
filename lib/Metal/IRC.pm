package Metal::IRC;

use Data::Printer;
use Moose;
use POE qw(Component::IRC::State Component::IRC::Plugin::NickServID Component::SSLify);
use Reflex::Event::NamedArgument;
use Reflex::POE::Session;
use Reflex::Trait::Watched qw(watches);

extends 'Reflex::Base';
with    qw(
    Metal::Role::Logger
    Reflex::Role::Reactive
);

our $VERSION = 0.01;

################################################################################

has component => (is => 'rw', isa => 'POE::Component::IRC::State', lazy_build => 1);
has trigger   => (is => 'ro', isa => 'Str',                        lazy_build => 1);

has config => (is => 'ro', isa => 'HashRef',       required => 1);
has db     => (is => 'ro', isa => 'Metal::Schema', required => 1);

has loaded_modules => (is => 'rw', isa => 'HashRef');

watches poco_watcher => (is => 'rw', isa => 'Reflex::POE::Session', role => 'poco');

################################################################################

sub BUILD {
    my $self = shift;

    $self->poco_watcher(Reflex::POE::Session->new({
        sid => $self->component->session_id,
    }));

    if ($self->config->{irc}->{nickserv_password}) {
        # POE::Component::IRC::Plugin::NickServID attempts to identify with
        # NickServ (and reidentifies where required)
        $self->component->plugin_add('NickServID', POE::Component::IRC::Plugin::NickServID->new(
            Password => $self->config->{irc}->{nickserv_password},
        ));
    }

    $self->run_within_session(sub {
        # _start event from POE::Component::IRC(::State)
        $self->component->yield(register => 'all');
        $self->component->yield(connect => {});
    });

    return 1;
}

sub message_channel {
    my $self    = shift;
    my $channel = shift;
    my $message = shift;

    # So modules can attempt an undef message (remove one layer of checks from
    # the module itself)
    return unless $message && $message ne '';

    eval { $self->component->yield('privmsg' => $channel => $message) };
    $self->logger->warn($@) if $@;

    return 1;
}

sub on_poco_irc_001 {
    my $self  = shift;
    my $event = shift;

    foreach (@{$self->config->{irc}->{channels}}) {
        $self->component->yield(join => $_);
    }

    return $self->_emit_named_argument_event('connected', {
        poco_args => $event->{args},
    });
}

sub on_poco_irc_public {
    my $self  = shift;
    my $event = shift;

    my $message      = $event->{args}->[2];
    my $full_host    = $event->{args}->[0];
    my @message_args = split / /, $message;
    my $trigger      = $self->trigger;
    my $command      = '';

    my ($nickname, $ident, $hostmask) = $full_host =~ /^(.+)!(.+)@(.+)$/;

    if ($message_args[0] =~ /^\Q$trigger\E/) {
        $command = shift @message_args;
        $command =~ s/^\Q$trigger\E//s;
    }

    return $self->_emit_named_argument_event('public', {
        full_host       => $full_host,
        hostmask        => $hostmask,
        nickname        => $nickname,
        channel         => $event->{args}->[1]->[0],
        message         => $message,
        command         => $command,
        message_args    => \@message_args,
        message_arg_str => join(' ', @message_args),
        poco_args       => $event->{args},
    });
}

sub on_poco_irc_chan_sync {
    my $self  = shift;
    my $event = shift;

    return $self->_emit_named_argument_event('chan_sync', {
        channel    => $event->{args}->[0],
        user_count => $event->{args}->[1],
        poco_args  => $event->{args},
    });
}

sub on_poco_irc_kick {
    my $self  = shift;
    my $event = shift;

    return $self->_emit_named_argument_event('kick', {
        poco_args => $event->{args},
        nickname  => $event->{args}->[2],
        channel   => $event->{args}->[1],
    });
}

sub on_poco_irc_nick {
    my $self  = shift;
    my $event = shift;

    my $old_nickname = $event->{args}->[0] =~ /^(.+)!/;

    return $self->_emit_named_argument_event('nick', {
        poco_args => $event->{args},
        channel   => $event->{args}->[2]->[0],
        nickname  => {
            old => $old_nickname,
            new => $event->{args}->[1],
        },
    });
}

sub on_poco_irc_nick_sync {
    my $self  = shift;
    my $event = shift;

    return $self->_emit_named_argument_event('nick_sync', {
        poco_args => $event->{args},
        nickname  => $event->{args}->[0],
        channel   => $event->{args}->[1],
    });
}

sub on_poco_irc_disconnected {
    my $self  = shift;
    my $event = shift;

    # TODO reconnect

    return $self->_emit_named_argument_event('disconnected', {
        poco_args => $event->{args},
        server    => $event->{args}->[0],
    });
}

################################################################################

sub _emit_named_argument_event {
    my $self = shift;
    my $name = shift;
    my $args = shift;

    return $self->emit(
        -name => $name,
        -type => 'Reflex::Event::NamedArgument',
        args  => $args,
    );
}

################################################################################

sub _build_component {
    my $self = shift;

    my $irc = $self->config->{irc};

    return POE::Component::IRC::State->spawn(
        server   => $irc->{server},
        port     => $irc->{port},
        nick     => $irc->{nickname},
        username => $irc->{ident},
        ircname  => $irc->{ircname},
        debug    => $irc->{debug},
        UseSSL   => $irc->{use_ssl},
    );
}

sub _build_trigger {
    my $self = shift;

    return $self->config->{irc}->{trigger} || '!';
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;

