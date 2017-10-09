package Metal;

# ABSTRACT: Base class for Metal IRC bot

use Moose;
use Term::ReadLine;
use Term::UI;
use utf8::all; # we're dealing with IRC so everything should be output in UTF-8

use Metal::IRC;
use Metal::Schema;
use Metal::Util::Config;

with 'Metal::Role::Logger';

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

    # Check if the bot has been launched before
    my $user_count = $self->db->resultset('User')->search_rs->count();

    $self->_first_run_setup() unless $user_count;
    $self->bot->loaded_modules($self->modules);

    return $self->bot->run_all();
}

################################################################################

sub _first_run_setup {
    my $self = shift;

    # If anything else is built like this, extract into a "Wizard" class.

    $self->logger->info('It appears to be your first run.');
    $self->logger->info('Running setup wizard');

    my $term = Term::ReadLine->new('Configuration');

    my $add_admin_user = $term->ask_yn(
        prompt  => 'Add an admin user?',
        default => 'y',
    );

    if ($add_admin_user) {
        my $nickname = $term->get_reply(prompt => 'Nickname');
        my $hostmask = $term->get_reply(prompt => 'Hostmask');

        my $user = $self->db->resultset('User')->create({
            name     => $nickname,
            hostmask => $hostmask,
        });

        $user->add_role('Admin');
    } else {
        $self->logger->info('You will need to manually give yourself the admin role in the database.');
    }

    return 1;
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

        $self->logger->debug("Loading ${module}...");

        require $file;

        $self->logger->debug("Loaded ${module}.");

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
__END__

