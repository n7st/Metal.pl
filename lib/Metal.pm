package Metal;

use Moose;

use Metal::IRC;
use Metal::Util::Config;

################################################################################

has config_file => (is => 'ro', isa => 'Str', required => 1);

has bot          => (is => 'ro', isa => 'Metal::IRC', lazy_build => 1);
has config       => (is => 'ro', isa => 'HashRef',    lazy_build => 1);
has modules      => (is => 'rw', isa => 'HashRef',    lazy_build => 1);
has module_names => (is => 'rw', isa => 'ArrayRef',   lazy_build => 1);

################################################################################

sub run {
    my $self = shift;

    $self->bot->loaded_modules($self->modules);

    # Initialise Reflex watchers
    foreach my $module (values %{$self->modules}) {
        $module->run_all();
    }

    return $self->bot->run_all();
}

################################################################################

sub _build_bot {
    my $self = shift;

    return Metal::IRC->new({
        config => $self->config,
    });
}

sub _build_config {
    my $self = shift;

    return Metal::Util::Config->new({
        filename => $self->config_file,
    })->config();
}

sub _build_modules {
    my $self = shift;

    my %modules;

    foreach my $module (@{$self->module_names}) {
        (my $file = $module.'.pm') =~ s{::}{/}g;

        require $file;

        $modules{$module} = $module->new({
            bot => $self->bot,
        });
    }

    return \%modules;
}

sub _build_module_names {
    my $self = shift;

    return $self->config->{loaded_modules} || {};
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;

