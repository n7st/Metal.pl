package Metal::Wizard::Configuration;

use Moose;
use Term::UI;
use Term::ReadLine;
use YAML::Syck;

extends 'Metal::Wizard';

with qw/
    Metal::Role::DB
    Metal::Role::Logger
    Metal::Role::Validation::IRC
/;

################################################################################

has term => (is => 'ro', isa => 'Term::UI', lazy_build => 1);

has servers => (is => 'rw', isa => 'ArrayRef[HashRef]', default => sub { [] });

################################################################################

sub _start {
    my $self = shift;

    my $reply;

    $reply = $self->term->get_reply(
        prompt => "How many connections would you like to add?",
        allow  => qr/\d+/,
    );

    push @{$self->steps}, { method => '_add_server'     } foreach (1..$reply);
    push @{$self->steps}, { method => '_confirm_commit' };

    return 1;
}

sub _add_server {
    my $self = shift;

    # Blank line if we've already queried server information more than once
    print STDOUT "\n" if $self->servers;

    push @{$self->servers}, {
        hostname => $self->term->get_reply(
            prompt => "Hostname",
            allow  => [ sub { $self->valid_hostname_or_ip(shift); } ],
        ),
        ident => $self->term->get_reply(
            prompt => "Username (ident)",
            allow  => $self->ident_regex,
        ),
        nickname => $self->term->get_reply(
            prompt => "Nickname",
            allow  => $self->nickname_regex,
        ),
        port => $self->term->get_reply(
            prompt => "Port",
            allow  => $self->port_regex,
        ),
        ssl => $self->term->ask_yn(
            prompt  => "SSL",
            default => "y",
        ),
        connect => $self->term->ask_yn(
            prompt  => "Should the bot connect to this server?",
            default => "y",
        ),
        join_chan => $self->term->ask_yn(
            prompt  => "Should the bot join channels?",
            default => "y",
        ),
        debug => $self->term->ask_yn(
            prompt  => "Debug (print lines received from server)",
            default => "y",
        ),
    };

    return 1;
}

sub _confirm_commit {
    my $self = shift;

    my $info = YAML::Syck::Dump($self->servers);

    print STDOUT $info;

    my $may_add = $self->term->ask_yn(
        prompt => "Does this look right?",
        default => "y",
    );

    if ($may_add) {
        foreach (@{$self->servers}) {
            $self->schema->resultset('Server')->create($_);
        }
    }

    return 1;
}

sub _end {
    my $self = shift;

    $self->logger->info("Last step");

    return 1;
}

################################################################################

sub _build_steps {
    return [{
        method => '_start',
    }];
}

sub _build_term {
    my $self = shift;

    my $term = Term::ReadLine->new('Configuration');

    return $term;
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;

