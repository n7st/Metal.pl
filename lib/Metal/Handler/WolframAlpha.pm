package Metal::Handler::WolframAlpha;

use Moose;
use WWW::WolframAlpha;

extends 'Metal::Handler';
with    'Metal::Roles::Config';

################################################################################

has wa => (is => 'ro', isa => 'WWW::WolframAlpha', lazy_build => 1);

################################################################################

sub query {
    my $self = shift;

    my $query = $self->wa->query(input => join ', ', @{$self->args->{list}});

    if ($query->success) {
        return $query->pods->[1]->subpods->[0]->plaintext;
    } else {
        return;
    }
}

################################################################################

sub _build_wa {
    WWW::WolframAlpha->new(appid => shift->config->{keys}->{wolfram_alpha});
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

