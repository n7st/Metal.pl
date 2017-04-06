package Metal::Role::Logger;

use Data::Dumper;
use Log::Log4perl qw/:easy/;
use Log::Log4perl::Level;
use Moose::Role;

################################################################################

has logger => (is => 'ro', isa => 'Log::Log4perl::Logger', lazy_build => 1);

################################################################################

sub logf {
    my $self  = shift;
    my $str   = shift;
    my $args  = shift;
    my $level = shift // 'info';

    my $out = sprintf($str, @{$args});

    return $self->logger->$level($out);
}

sub log_dump {
    my $self = shift;
    my $args = shift;

    my $level = $args->{level} // 'info';

    return $self->logger->$level(Dumper($args->{content}));
}

################################################################################

sub _build_logger {
    my $self = shift;

    Log::Log4perl->easy_init($DEBUG);

    return Log::Log4perl->get_logger();
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Role::Logger

=head1 DESCRIPTION

Easy logging class for Moose classes.

=head2 USAGE

    use Moose;

    with 'Metal::Role::Logger';

    sub something {
        my $self = shift;

        $self->logger->debug("Something happened");

        my $valid = $self->_is_it_valid();

        unless ($valid) {
            $self->logger->warn("It isn't valid!");
        }

        return;
    }

=head2 CUSTOM LOGGING METHODS

=over 4

=item C<log_dump()>

Dump an object to the logger using Data::Dumper.

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

