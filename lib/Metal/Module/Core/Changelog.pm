package Metal::Module::Core::Changelog;

use Moose;

extends 'Metal::Module';

################################################################################

has changelog_location => (is => 'ro', isa => 'Maybe[Str]', lazy_build => 1);

################################################################################

sub on_bot_public {
    my $self  = shift;
    my $event = shift;

    if ($event->{args}->{command} eq 'changelog') {
        # If the changelog location isn't set, message_channel will not send
        $self->bot->message_channel($event->{args}->{channel}, $self->changelog_location);
    }

    return 1;
}

################################################################################

sub _build_changelog_location {
    my $self = shift;

    return $self->bot->config->{changelog};
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;
__END__

=head1 NAME

Metal::Module::Core::Changelog

=head1 DESCRIPTION

Sends a link to the bot's changelog to the IRC channel.

=head2 ATTRIBUTES

=over 4

=item C<changelog_location>

The URL for the changelog or undef.

=back

=head2 METHODS

=over 4

=item C<on_bot_public()>

Runs on every public message. Sends the changelog if requested.

=back

