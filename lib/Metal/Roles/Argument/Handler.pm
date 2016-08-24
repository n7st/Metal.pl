package Metal::Roles::Argument::Handler;

use Moose::Role;

with 'Metal::Roles::User';

################################################################################

sub args_as_hashref {
    my $self = shift;
    my @args = @_; # List of POE::Component::IRC arguments

    my ($nick, $host)  = $self->split_nick_and_host($args[6]);
    my ($ident, $mask) = $self->split_ident_and_mask($host);

    return {
        input_location => $args[7][0],
        list           => $self->_argument_list($args[8]),
        original       => $args[8],

        from => {
            host          => $host,
            hostmask      => $mask,
            ident         => $ident,
            nick          => $nick,
            is_identified => $self->is_identified($mask),
        },
    };
}

################################################################################

sub _argument_list {
    my $self   = shift;
    my $string = shift;

    # Boilerplate in case of future additions

    my @args = split /\ /, $string;

    return \@args;
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Roles::Argument::Handler

=head1 DESCRIPTION

