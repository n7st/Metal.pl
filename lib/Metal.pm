package Metal;

use Module::Pluggable search_path => [ 'Metal' ];
use Moose;

use Metal::Gateway;

with qw/
    Metal::Role::Cache
    Metal::Role::Config
    Metal::Role::Logger
/;

our $VERSION = 0.01;

################################################################################

has handlers => (is => 'ro', isa => 'HashRef', lazy_build => 1);

################################################################################

sub run {
    my $self = shift;

    $self->clear_runlist(); # from the cache role

    my $gw = Metal::Gateway->new({ handlers => $self->handlers });

    return $gw->connect();
}

################################################################################

sub _build_handlers {
    my $self = shift;

    my $enabled_handlers = $self->config->{handlers};
    my %ret;

    # Build a map of available event handlers (IRC numeric events or custom
    # signals)
    foreach my $name (keys %{$enabled_handlers}) {
        my $class = 'Metal::Handler::'.$enabled_handlers->{$name};

        $self->logger->info("Loading handler class: ".$class);

        eval "require $class";

        $self->logger->warn($@) if $@;
        $ret{$name} = eval { $class->new() };
        $self->logger->warn($@) if $@;
    }

    return \%ret;
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal - Modular IRC framework.

=head2 USAGE

    my $metal = Metal->new();

    $metal->run();

=head2 METHODS

=over 4

=item C<run()>

Connect to the gateway and run the main loop.

=item C<_build_handlers()>

Instantiate handler classes and return a usable HashRef.

=back

=head1 SEE ALSO

=over 4

=item C<Metal::Gateway>

Spawn bots and set their package states to Handler classes.

=item C<Metal::Handler::External::Message>

Mapper class for message items spooled from the IRC network (public, private,
notice...).

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

