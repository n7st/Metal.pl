package Metal::Roles::User;

use Moose::Role;

################################################################################

sub is_identified {
    my $self = shift;
    my $host = shift;

    return $host =~ /\//;
}

sub user_from_host {
    my $self = shift;
    my $host = shift;
    my $nick = shift;

    return unless $host;

    my $user = $self->schema->resultset('User')->find_or_new({
        hostmask => $host,
    });

    unless ($user->in_storage()) {
        $user->name($nick);
        $user->insert();
    }

    return $user;
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

