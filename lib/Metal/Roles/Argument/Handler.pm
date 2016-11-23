package Metal::Roles::Argument::Handler;

use Moose::Role;

with 'Metal::Roles::User';

################################################################################

sub args_as_hashref {
    my $self = shift;
    my $type = shift;
    my @args = @_; # List of POE::Component::IRC arguments

    my ($nick, $host)  = $self->split_nick_and_host($args[6]);
    my ($ident, $mask) = $self->split_ident_and_mask($host);

    my @arg_list       = $self->_argument_list($args[8]);
    my @clean_arg_list = shift @arg_list;

    return {
        input_location => $type eq 'PUBLIC' ? $args[7][0] : $nick,
        list           => \@arg_list       || [],
        list_with_cmd  => \@clean_arg_list || [],
        original       => $args[8],
        string         => join(' ', @arg_list),

        from => {
            host          => $host,
            hostmask      => $mask,
            ident         => $ident,
            nick          => $nick,
            is_identified => $self->is_identified($mask) ? 1 : 0,
        },
    };
}

################################################################################

sub _argument_list {
    my $self   = shift;
    my $string = shift;

    # Boilerplate in case of future additions

    return split /\ /, $string;
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Roles::Argument::Handler

=head1 DESCRIPTION

