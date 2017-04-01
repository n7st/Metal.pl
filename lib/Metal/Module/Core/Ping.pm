package Metal::Module::Core::Ping;

use Moose;

extends 'Metal::Module';

################################################################################

sub ping {
    my $self = shift;
    my $args = shift;
    my $poe  = shift;

    push @{$self->reply}, "Pong";

    return 1;
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Module::Core::Ping

=head1 DESCRIPTION

Pong.

=head2 METHODS

=over 4

=item C<pong()>

"I'm alive".

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

