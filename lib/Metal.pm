package Metal;

# ABSTRACT: Metal IRC framework

use Module::Pluggable search_path => [ 'Metal' ];
use Moose;

use Metal::Bot;
use Metal::Handler::Creator;
use Metal::Wizard::Configuration;

with qw/
    Metal::Role::Config
    Metal::Role::DB
    Metal::Role::Logger
    Metal::Role::Validation::IRC
/;

our $VERSION = 0.011;

################################################################################

sub run {
    my $self = shift;

    my @servers = $self->schema->resultset('Server')->all();

    unless (scalar @servers) {
        $self->logger->info("First run");

        # TODO run $self->configure()
    }

    my $bot = Metal::Bot->new();

    return $bot->run();
}

sub new_handler {
    my $self = shift;
    my $args = shift;

    unless ($args->{name}) {
        $self->logger->warn("A `name` argument is required by Metal::Handler::Creator");

        return 0;
    }

    my $gen = Metal::Handler::Creator->new($args);

    return $gen->generate();
}

sub configure {
    my $self = shift;

    my $wizard = Metal::Wizard::Configuration->new();

    return $wizard->walk();
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal

=head1 DESCRIPTION

Main class for the framework. Provides access to a variety of functions from
the command-line.

=head2 SYNOPSIS

    use Metal;

    my $metal = Metal->new();

    # Run the bot
    $metal->run();

=head2 METHODS

=over 4

=item C<run()>

Run IRC bots.

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

