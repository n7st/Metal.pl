package Metal::Handler::Event;

use Data::Printer;
use DateTime;
use Moose;

################################################################################

extends 'Metal::Handler';
with    qw/
    Metal::Roles::Config
    Metal::Roles::DB
    Metal::Roles::User
/;

################################################################################

around qw/create update delete/ => sub {
    my $orig = shift;
    my $self = shift;

    my $user = $self->db->resultset('User')->from_host($self->args->{from});

    # User requires 'event' permission to modify database

    return $self->$orig(@_, $user) if $user->has_permission('event');
    return "You do not have permission to modify event notifications.";
};

################################################################################

sub create {
    my $self = shift;
    my $user = shift;

    my $args = $self->_validate_args($self->args->{list});

    p $args;

    return;
}

sub read {
    my $self = shift;

    return;
}

sub update {
    my $self = shift;
    my $user = shift;

    my $args = $self->_validate_args($self->args->{list});

    return;
}

sub delete {
    my $self = shift;
    my $user = shift;

    return;
}

################################################################################

sub _validate_args {
    my $self = shift;
    my $args = shift;

    my $date = shift @{$args};
    my $name = shift @{$args};

    return {
        date      => $date,
        name      => $name,
        long_name => undef,
    };
}

################################################################################

no Moose;
1;

