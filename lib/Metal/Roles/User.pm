package Metal::Roles::User;

use Moose::Role;

################################################################################

sub is_identified {
    my $self = shift;
    my $host = shift;

    return $host =~ /\//;
}

sub split_ident_and_mask {
    my $self   = shift;
    my $string = shift;

    return split /@/, $string;
}

sub split_nick_and_host {
    my $self   = shift;
    my $string = shift;

    return split /!/, $string;
}

################################################################################

no Moose;
1;
__END__

