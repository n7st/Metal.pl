package Metal::Module::Replacement;

use Moose;

extends 'Metal::Module';
with    'Metal::Role::Random';

################################################################################

has minimum          => (is => 'ro', isa => 'Int', lazy_build => 1);
has replacement_word => (is => 'ro', isa => 'Str', lazy_build => 1);

################################################################################

sub on_bot_public {
    my $self  = shift;
    my $event = shift;

    if ($self->sometimes($self->minimum)) {
        my @words = @{$event->{args}->{message_args}};
        my $count = scalar @words - 1;
        my $index = int(rand($count));

        splice(@words, $index, 1, $self->replacement_word);

        $self->bot->message_channel($event->{args}->{channel}, join(' ', @words));
    }

    return 1;
}

################################################################################

sub _build_minimum {
    my $self = shift;

    return $self->bot->config->{replacement}->{minimum} // 990;
}

sub _build_replacement_word {
    my $self = shift;

    return $self->bot->config->{replacement}->{word} // 'butts';
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;
__END__

=head1 NAME

Metal::Module::Replacement

=head1 DESCRIPTION

Replaces a random word in the incoming message (with 'butts' by default) and
sends it back.

=head2 METHODS

=over 4

=item C<on_bot_public()>

Runs whenever a public message is received. Checks a randomly generated number
against its minimum threshold (C<minimum>), and if it's greater, replaces a
random word in the sentence with the replacement word (C<replacement_word>).

=back

