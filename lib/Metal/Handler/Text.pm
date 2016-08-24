package Metal::Handler::Text;

use Moose;

extends 'Metal::Handler';

################################################################################

sub dadjoke { sprintf("Hahahaha! %s, you're so funny!", shift->args->{nick}); }

sub damson { 'https://i.imgur.com/7lZwLKc.jpg'; }

sub eatpizza { '............................................pizza'; }

sub flenny {
    my $self = shift;

    my @flennies = (
        '',
        '',
    );

    return $flennies[rand @flennies];
}

sub lemmy { ''; }

sub lenny {
    my $self = shift;

    my @lennies = (
        '',
        '',
        '',
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

