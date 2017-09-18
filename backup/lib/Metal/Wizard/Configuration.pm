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

################################################################################

sub add_server {
    my $self = shift;

    my $add = $self->term->ask_yn(
        prompt  => "Add a server?",
        default => "y",
    );

    while ($add == 1) {
        # Blank line if we've already queried server information more than once
        print STDOUT "\n";

        my $config = {
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

        my $server = $self->_confirm_commit($config);

        $self->_add_channels({ first_run => 1, server => $server });

        $add = $self->term->ask_yn(
            prompt  => "Add a server?",
            default => "y",
        );
    }

    return 1;
}

sub select_modules {
    my $self = shift;
    my $args = shift;

    # TODO

    return 1;
}

################################################################################

sub _add_channels {
    my $self = shift;
    my $args = shift;

    my $add = 1;

    do {
        $add = $self->term->ask_yn(
            prompt  => "Add a channel for the bot?",
            default => $args->{first_run} ? "y" : "n",
        );

        $args->{first_run} = 0;

        if ($add) {
            my $name = $self->term->get_reply(
                prompt => "Name",
                allow  => $self->channel_regex,
            );

            $args->{server}->create_related("channels", { name => $name });
        }
    } until $add == 0;

    return 1;
}

sub _confirm_commit {
    my $self   = shift;
    my $server = shift;

    my $info = YAML::Syck::Dump($server);

    print STDOUT $info;

    my $may_add = $self->term->ask_yn(
        prompt  => "Does this look right?",
        default => "y",
    );

    if ($may_add) {
        my $server = $self->schema->resultset('Server')->create($server);

        return $server;
    }

    return;
}

################################################################################

sub _build_steps {
    return [{
        method => 'add_server',
        method => 'select_modules',
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
__END__

=head1 NAME

Metal::Wizard::Configuration

=head1 DESCRIPTION

Set up server connections for bots.

=head2 METHODS

=over 4

=item C<_add_server()>

Until the user selects "no", add server connections.

=item C<_add_channels()>

Until the user selects "no", add channels to the connection.

=item C<_confirm_commit()>

Confirm the server's data is correct and commit to the database if it is.

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

