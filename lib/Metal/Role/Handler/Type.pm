package Metal::Role::Handler::Type;

use List::Util qw/any/;
use Moose::Role;

################################################################################

has event_type => (is => 'ro', isa => 'Str', default => 'Event');
has task_type  => (is => 'ro', isa => 'Str', default => 'Task');

has all_types => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);

################################################################################

sub is_event_type {
    my $self = shift;
    my $type = shift;

    return $type eq $self->event_type;
}

sub is_task_type {
    my $self = shift;
    my $type = shift;

    return $type eq $self->task_type;
}

sub is_valid_event_type {
    my $self = shift;
    my $type = shift;

    return any { $_ eq $type } @{$self->all_types};
}

################################################################################

sub _build_all_types {
    my $self = shift;

    return [
        $self->event_type,
        $self->task_type,
    ];
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Role::Handler::Type

=head1 DESCRIPTION

Methods for checking handler types.

=head2 USAGE

    with 'Metal::Role::Handler::Type';

    sub do_something_if_task_type {
        my $self = shift;

        my $handler = Metal::Handler::Internal::Task::Test->new();

        if ($self->is_task_type($handler->type)) {
            # It's a Task
        } else {
            # It's not a Task
        }
    }

=head2 METHODS

=over 4

=item C<is_event_type()>

Validate that the type is 'Event'.

=item C<is_task_type()>

Validate that the type is 'Task'.

=item C<is_valid_event_type()>

Validate that the type is valid and exists.

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

