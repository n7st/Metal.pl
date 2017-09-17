package Metal::Role::MessagePart;

use Moose::Role;

################################################################################

has max_len => (is => 'ro', isa => 'Int', default => 400);

################################################################################

sub message_to_parts {
    my $self    = shift;
    my $message = shift;

    # Should be run on messages over the max length of 400 - should the
    # attribute be defined elsewhere for access?

    my $max_len = $self->max_len;
    my @parts   = unpack "(A${max_len})*", $message;

    # TODO: trim trailing and leading whitespace?

    return \@parts;
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Role::MessagePart

=head1 DESCRIPTION

Splits a message into equal size parts of a length defined in attribute
C<max_len>.

=head2 ATTRIBUTES

=over 4

=item C<max_len>

The length of strings in the parts list returned by C<message_to_parts()>. This
is currently set to 400 for space for the rest of the raw line, and the real
maximum length per IRCv2 specifications is 512.

=back

=head2 METHODS

=over 4

=item C<message_to_parts()>

Splits the message into parts of length defined in attribute C<max_len> and
returns them in a list.

=back

