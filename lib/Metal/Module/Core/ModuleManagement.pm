package Metal::Module::Core::ModuleManagement;

use List::Util qw(any first);
use Moose;

extends 'Metal::Module';
with    qw(
    Metal::Role::Logger
    Metal::Role::UserOrArg
    Metal::Module::Role::WithCommands
);

################################################################################

around [ qw(_load _unload) ] => sub {
    my $orig = shift;
    my $self = shift;
    my $args = shift;

    my $current_user = $self->user_or_arg($args, { skip_args => 1 });

    return unless $current_user->has_role('Admin');

    my $module_name = $args->{message_args}->[0];

    return 'No module name provided' unless $module_name;

    my $kx = first { $_ eq $module_name } keys %{$self->bot->loaded_modules};

    return "No such module: ${module_name}" unless $kx;

    my $module = $self->bot->loaded_modules->{$kx};

    return "Could not unload ${module_name}" unless $module->can('unloaded');
    return $self->$orig($args, $module, $module_name);
};

sub _list_modules {
    my $self = shift;

    my @modules;

    foreach (keys %{$self->bot->loaded_modules}) {
        my $module = $self->bot->loaded_modules->{$_};

        next if $module->can('unloaded') && $module->unloaded == 1;

        my ($name) = $_ =~ /^Metal::Module::(.+)$/;

        push @modules, $name;
    }

    return join ', ', @modules;
}

sub _load {
    my $self        = shift;
    my $args        = shift;
    my $module      = shift;
    my $module_name = shift;

    $module->unloaded(0);

    return "Loaded ${module_name}";
}

sub _unload {
    my $self        = shift;
    my $args        = shift;
    my $module      = shift;
    my $module_name = shift;

    $module->unloaded(1);

    return "Unloaded ${module_name}";
}

################################################################################

sub _build_commands {
    return {
        load    => '_load',
        modules => '_list_modules',
        unload  => '_unload',
    };
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;
__END__

=head1 NAME

Metal::Module::Core::ModuleManagement

=head1 DESCRIPTION

Commands related to management and listing of the bot's loaded modules.

=head2 METHODS

=over 4

=back

