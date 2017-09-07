package Metal;

use Moose;
use utf8::all; # we're dealing with IRC so everything should be output in UTF-8

use Metal::IRC;
use Metal::Schema;
use Metal::Util::Config;

################################################################################

has config_file => (is => 'ro', isa => 'Str', required => 1);

has bot          => (is => 'ro', isa => 'Metal::IRC',    lazy_build => 1);
has config       => (is => 'ro', isa => 'HashRef',       lazy_build => 1);
has db           => (is => 'ro', isa => 'Metal::Schema', lazy_build => 1);
has module_names => (is => 'rw', isa => 'ArrayRef',      lazy_build => 1);
has modules      => (is => 'rw', isa => 'HashRef',       lazy_build => 1);

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
        db     => $self->db,
    });
}

sub _build_config {
    my $self = shift;

    return Metal::Util::Config->new({
        filename => $self->config_file,
    })->config();
}

sub _build_db {
    my $self = shift;

    return Metal::Schema->connect($self->config->{db}->{dsn}, '', '', {
        RaiseError => 1,
    });
}

sub _build_modules {
    my $self = shift;

    my %modules;

    # Dynamically include each module an instantiate it
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

