package Metal::Handler::WolframAlpha;

use Moose;
use WWW::WolframAlpha;

extends 'Metal::Handler';

################################################################################

has wa => (is => 'ro', isa => 'WWW::WolframAlpha', lazy_build => 1);

################################################################################

sub query {
    my $self = shift;

    my $query = $self->wa->query(input => join ', ', @{$self->args->{list}});

    use DDP;

    p $query;
    if ($query->success) {
        return $query->pods->[1]->subpods->[0]->plaintext;
    } else {
        return;
    }
}

################################################################################

sub _build_wa {
    my $self = shift;

    return WWW::WolframAlpha->new(appid => 'X428HK-QEJK9Y52P2');
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

