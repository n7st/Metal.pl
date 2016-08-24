package Metal::Roles::Argument::Handler;

use Moose::Role;

################################################################################

sub as_hashref {
    my $self = shift;
    my @args = @_; # List of POE::Component::IRC arguments

    my ($nick, $host)  = $self->_nick_host($args[6]);
    my ($ident, $mask) = $self->_ident_mask($host);

    return {
        input_location => $args[7][0],
        original       => $args[8],
        as_list        => $self->_argument_list($args[8]),

        from => {
            host          => $host,
            hostmask      => $mask,
            ident         => $ident,
            nick          => $nick,
            is_identified => $self->_is_identified($mask),
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

sub _ident_mask {
    my $self   = shift;
    my $string = shift;

    # Boilerplate in case of future additions

    return split /@/, $string;
}

sub _is_identified {
    my $self     = shift;
    my $hostmask = shift;

    # For now we'll pretend all identified users have slashes in their hosts
    my $identified = $hostmask =~ /\//;

    # TODO get response from user whois to determine if they're identified

    return $identified;
}

sub _nick_host {
    my $self   = shift;
    my $string = shift;

    # Boilerplate in case of future additions

    return split /!/, $string;
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Roles::Argument::Handler

=head1 DESCRIPTION

