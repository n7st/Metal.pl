package Metal::Wizard;

use Moose;

################################################################################

has steps => (is => 'rw', isa => 'ArrayRef[HashRef]', lazy_build => 1);

################################################################################

sub walk {
    my $self = shift;

    foreach (@{$self->steps}) {
        my $method = $_->{method};

        $self->$method($_->{args} // {});
    }

    return 1;
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;
__END__

=head1 NAME

Metal::Wizard

