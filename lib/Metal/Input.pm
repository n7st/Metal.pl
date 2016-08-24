package Metal::Input;

use Data::Printer;
use Moose;

extends 'Metal';

with qw/
    Metal::Roles::Argument::Handler
    Metal::Roles::Routes
    Metal::Roles::DB
/;

################################################################################

has args => (is => 'rw', isa => 'HashRef');

################################################################################

sub start {
}

sub irc_001 {
}

sub irc_public {
    my $self    = shift;
    my $session = shift;
    my $kernel  = shift;
    my $heap    = shift;
}

sub irc_private {
    my $self    = shift;
    my $session = shift;
    my $kernel  = shift;
    my $heap    = shift;
}

sub irc_notice {
    my $self    = shift;
    my $session = shift;
    my $kernel  = shift;
    my $heap    = shift;
}

sub test_input {
    my $self    = shift;
    my $command = shift;
    my $args    = shift;

    my $command_info = $self->routes->{$command};
    my $output;

    if ($command_info) {
        my $class   = $command_info->{class}->new({ args => $args });
        my $routine = $command_info->{routine};

        $output = $class->$routine();
    }

    return $output;
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Input

=head1 DESCRIPTION

Converts signals passed by POE::Component::IRC into commands which may be in
Metal::Roles::Routes.

=head1 SEE ALSO

=over 4

=item C<Metal::Roles::Routes>

Mapping hash for command => class, method.

=back

=head1 AUTHOR

Mike Jones <mike@netsplit.org.uk>

