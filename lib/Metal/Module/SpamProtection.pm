package Metal::Module::SpamProtection;

use Moose;

extends 'Metal::Module';

################################################################################

has channels => (is => 'rw', isa => 'HashRef', default => sub { {} });

has config       => (is => 'ro', isa => 'HashRef', lazy_build => 1);
has our_nickname => (is => 'rw', isa => 'Str',     lazy_build => 1);

################################################################################

with qw(
    Metal::Role::Access
    Metal::Role::Logger
    Metal::Module::Role::SpamProtection::Qualification
);

################################################################################

sub on_bot_connected {
    my $self  = shift;
    my $event = shift;

    $self->our_nickname($self->bot->component->{INFO}->{RealNick});

    return 1;
}

sub on_bot_public {
    my $self  = shift;
    my $event = shift;

    my $message  = $event->{args}->{message};
    my $channel  = $event->{args}->{channel};
    my $nickname = $event->{args}->{nickname};
    my $hostname = $event->{args}->{hostmask};

    unless ($self->meets_min_msg_requirements($message)) {
        # Don't do heavy lifting for short messages
        return 1;
    }

    return unless $hostname;

    if ($self->config->{spam_protection}->{non_utf8} && $self->meets_msg_max_non_utf8_count($message)) {
        $self->_perform_ban($channel, $nickname, $hostname, 'Spam');
    }

    if ($self->config->{mass_hl} && $self->meets_msg_max_highlight_count($message, $channel)) {
        $self->_perform_ban($channel, $nickname, $hostname, 'Mass highlighting');
    }

    return 1;
}

sub _perform_ban {
    my $self     = shift;
    my $channel  = shift;
    my $nickname = shift;
    my $hostname = shift;
    my $reason   = shift;

    if ($self->has_channel_access($channel, $self->our_nickname)) {
        $self->bot->component->yield('kick' => $channel => $nickname => $reason);
        $self->bot->component->yield('mode' => "${channel} +b *!*\@${hostname}");
    } else {
        $self->logger->warn("Bot does not have channel access to perform a ban (${channel})");
    }

    return 1;
}

sub on_bot_chan_sync {
    my $self  = shift;
    my $event = shift;

    my @nicks = $self->bot->component->channel_list($event->{args}->{channel});

    my $channel_info = $self->channels;

    $channel_info->{$event->{args}->{channel}} = { map { $_ => 1 } @nicks };

    $self->channels($channel_info);

    return 1;
}

sub on_bot_nick {
    my $self  = shift;
    my $event = shift;

    if ($event->{args}->{nickname}->{old} eq $self->our_nickname) {
        # Bot's nickname was changed, reset to its new one
        $self->our_nickname($event->{args}->{nickname}->{new});
    }

    return $self->_update_channel_nick_list({
        channel  => $event->{args}->{channel},
        nickname => $event->{args}->{nickname},
    });
}

sub on_bot_kick {
    my $self  = shift;
    my $event = shift;

    return $self->_update_channel_nick_list({
        channel  => $event->{args}->{channel},
        nickname => { old => $event->{args}->{nickname} },
    });
}

sub on_bot_nick_sync {
    my $self  = shift;
    my $event = shift;

    return $self->_update_channel_nick_list({
        channel  => $event->{args}->{channel},
        nickname => { new => $event->{args}->{nickname} },
    });
}

################################################################################

sub _update_channel_nick_list {
    my $self = shift;
    my $args = shift;

    my $channel_info = $self->channels;

    if ($args->{nickname}->{new}) {
        $channel_info->{$args->{channel}}->{$args->{nickname}->{new}} = 1;
    }

    if ($args->{nickname}->{old}) {
        $channel_info->{$args->{channel}}->{$args->{nickname}->{old}} = 0;
    }

    $self->channels($channel_info);

    return 1;
}

################################################################################

sub _build_config {
    my $self = shift;

    return $self->bot->config->{spam_protection} // {};
}

sub _build_our_nickname {
    my $self = shift;

    return $self->bot->config->{irc}->{nickname};
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;

