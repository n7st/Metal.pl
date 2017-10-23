package Metal::Module::Releases;

use JSON::XS    'decode_json';
use LWP::Simple 'get';
use Moose;

extends 'Metal::Module';
with    qw(
    Metal::Role::Logger
    Metal::Module::Role::Blockable
);

################################################################################

has base_url => (is => 'ro', isa => 'Maybe[Str]', lazy_build => 1);
has commands => (is => 'ro', isa => 'HashRef',    lazy_build => 1);

################################################################################

sub on_bot_public {
    my $self  = shift;
    my $event = shift;

    my $output = $self->_attempt_command($event->{args});

    $self->bot->message_channel($event->{args}->{channel}, $output);

    return 1;
}

################################################################################

sub _releases {
    my $self = shift;
    my $args = shift;

    unless ($self->base_url) {
        $self->logger->warn("releases:base_url config variable missing");

        return;
    }

    my $json    = get($self->base_url);
    my $content = decode_json($json);

    return $content->{display} || '';
}

################################################################################

sub _build_base_url {
    my $self = shift;

    return $self->bot->config->{releases}->{base_url};
}

sub _build_commands {
    return {
        releases => '_releases',
    };
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;

