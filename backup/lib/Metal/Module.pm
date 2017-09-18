package Metal::Module;

use Moose;

################################################################################

has action => (is => 'rw', isa => 'ArrayRef', default => sub { [] });
has reply  => (is => 'rw', isa => 'ArrayRef', default => sub { [] });

################################################################################

sub all {
    my $self = shift;
    my $args = shift;
    my $poe  = shift;

    my $command = $args->{message}->{command} // return;

    if ($self->can($command)) {
        $self->$command($args, $poe);

        return 1;
    }

    return 0;
}

sub reset {
    my $self = shift;

    $self->reply([]);
    $self->action([]);

    return 1;
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Module

=head1 DESCRIPTION

A base class for Metal's modules.

=head2 METHODS

=over 4

=item C<all()>

Attempt to run commands inside the modules. Passing a command of "test" will
look for a method called `test` in the module.

In a subclass, you may run code before this method happens by using a Moose
"before" call:

    before 'all' => sub {
        my $self = shift;
        my $args = shift;

        if ($args->{message} =~ /something/) {
            $self->do_something();
        }
    };

=item C<reset()>

Clear stored module messages.

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

