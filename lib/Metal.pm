package Metal;

use Module::Pluggable search_path => [ 'Metal' ];
use Moose;

use Metal::Bot;

with qw/
    Metal::Role::Config
    Metal::Role::Logger
/;

our $VERSION = 0.011;

################################################################################

sub run {
    my $self = shift;

    my $bot = Metal::Bot->new();

    return $bot->run();
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

