package Metal::Module::Lenny;

use Moose;

extends 'Metal::Module';
with    qw(
    Metal::Module::Role::Blockable
    Metal::Module::Role::WithCommands
);

################################################################################

has commands                 => (is => 'ro', isa => 'HashRef',  lazy_build => 1);
has [ qw(flennies lennies) ] => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);

################################################################################

sub _flenny {
    my $self = shift;
    my $args = shift;

    return $self->flennies->[rand @{$self->flennies}];
}

sub _lenny {
    my $self = shift;
    my $args = shift;

    return $self->lennies->[rand @{$self->flennies}];
}

sub _lemmy {
    return '( ͡° ͜ʖ ͡°:)';
}

################################################################################

sub _build_commands {
    return {
        flenny => '_flenny',
        lemmy  => '_lemmy',
        lenny  => '_lenny',
    };
}

sub _build_flennies {
    return [
        '(    ◉ ͜  ͡◔    )',
        '(    ͡^ ͜  ͡^    )',
    ];
}

sub _build_lennies {
    return [
        '( ͜。 ͡ʖ ͜。)',
        '( ͡° ͜ʖ ͡°)',
        'ᕦ( ͡° ͜ʖ ͡°)ᕤ',
    ];
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;
__END__

=head1 NAME

Metal::Module::Lenny

=head1 DESCRIPTION

Lenny faces for IRC.

=head2 METHODS

=over 4

=item C<_flenny()>

=item C<_lemmy()>

=item C<_lenny()>

=back

