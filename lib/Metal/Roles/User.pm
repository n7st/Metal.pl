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

################################################################################

no Moose;
1;
__END__

