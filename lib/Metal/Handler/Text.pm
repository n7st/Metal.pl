package Metal::Handler::Text;

use Moose;

extends 'Metal::Handler';

################################################################################

sub damson   { 'https://i.imgur.com/7lZwLKc.jpg';                   }
sub eatpizza { '............................................pizza'; }

sub dadjoke {
    my $self = shift;

    return sprintf(
        "Hahahaha! %s, you're so funny!",
        $self->args->{from}->{nick}
    );
}

sub flenny {
    my $self = shift;

    my @flennies = (
        '(    ◉ ͜  ͡◔    )',
        '(    ͡^ ͜  ͡^    )',
    );

    return $flennies[rand @flennies];
}

sub lemmy { '( ͡° ͜ʖ ͡°:)'; }

sub lenny {
    my $self = shift;

    my @lennies = (
        '( ͜。 ͡ʖ ͜。)',
        '( ͡° ͜ʖ ͡°)',
        'ᕦ( ͡° ͜ʖ ͡°)ᕤ',
    );

    return $lennies[rand @lennies];
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Handler::Text

=head1 DESCRIPTION

Basic text outputs.

=head1 AUTHOR

Mike Jones <mike@netsplit.org.uk>

