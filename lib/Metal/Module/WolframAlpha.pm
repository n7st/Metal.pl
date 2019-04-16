package Metal::Module::WolframAlpha;

use Moose;
use WWW::WolframAlpha;

extends 'Metal::Module';
with    qw(
    Metal::Role::Config
    Metal::Module::Role::Blockable
    Metal::Module::Role::WithCommands
);

################################################################################

has wa => (is => 'ro', isa => 'WWW::WolframAlpha', lazy_build => 1);

################################################################################

sub _query {
    my $self = shift;
    my $args = shift;

    my $query = $self->wa->query(
        format   => 'plaintext',
        input    => $args->{message_arg_str},
        podtitle => 'Result',
    );

    my $response = 'No results.';

    if ($query->success && @{$query->pods} > 0) {
        my $result = $query->pods->[0];

        if ($result && @{$result->subpods} > 0) {
            $response = $result->subpods->[0]->plaintext;
        }
    }

    return $response;
}

################################################################################

sub _build_commands {
    return {
        wa => '_query',
    }
}

sub _build_wa {
    my $self = shift;

    unless ($self->config->{wolfram_alpha}->{api_key}) {
        # TODO: proper exceptions
        die 'No API key provided (wolfram_alpha.api_key)';
    }

    return WWW::WolframAlpha->new(
        appid => $self->config->{wolfram_alpha}->{api_key},
    );
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;

