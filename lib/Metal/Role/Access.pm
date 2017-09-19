package Metal::Role::Access;

use Moose::Role;

requires qw(bot);

################################################################################

sub has_channel_access {
    my $self     = shift;
    my $channel  = shift;
    my $nickname = shift;

    return 0 unless $channel && $nickname;

    my $component = $self->bot->component;

    return $component->is_channel_admin($channel, $nickname) ||
        $component->is_channel_halfop($channel, $nickname)   ||
        $component->is_channel_operator($channel, $nickname) ||
        $component->is_channel_owner($channel, $nickname)    ||
        $component->is_operator($nickname);
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Role::Access - check whether a user has access to a channel.

=head1 DESCRIPTION

=head2 METHODS

=over 4

=item C<has_channel_access()>

Fall through until matching access is found (or return false).

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

