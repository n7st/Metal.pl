package Metal::Module::ModuleManagement;

use Class::Unload;
use Data::Printer;
use List::Util qw(first);
use Moose;

extends 'Metal::Module';
with    'Metal::Role::Logger';

################################################################################

sub on_bot_public {
    my $self  = shift;
    my $event = shift;

    my $output;

    if ($event->{args}->{command} eq 'modules') {
        $output = $self->_list_modules();
    } elsif ($event->{args}->{command} eq 'unload') {
        #$output = $self->_unload_module($event->{args}->{message_args}->[0]);
    } elsif ($event->{args}->{command} eq 'load') {
        #$output = $self->_load_module($event->{args}->{message_args}->[0]);
    }

    $self->bot->message_channel($event->{args}->{channel}, $output);

    return 1;
}

################################################################################

sub _list_modules {
    my $self = shift;

    my @modules;

    foreach (keys %{$self->bot->loaded_modules}) {
        my ($module) = $_ =~ /^Metal::Module::(.+)$/;

        push @modules, $module;
    }

    return join ', ', @modules;
}

=cut
sub _load_module {
    my $self   = shift;
    my $module = shift;

    my $full_name = "Metal::Module::${module}";

    return 'A module name is required'   unless $module;
    return 'You cannot load this module' if $full_name eq __PACKAGE__;

    my $loaded_modules = $self->bot->loaded_modules;;

    eval {
        (my $file = $full_name.'.pm') =~ s{::}{/}g;

        require $file;

        $loaded_modules->{$full_name} = $full_name->new({
            bot => $self->bot,
        });
    };
    if ($@) {
        return 'Module could not be loaded';
    }

    $self->bot->loaded_modules($loaded_modules);

    return "Loaded ${module}";
}

sub _unload_module {
    my $self   = shift;
    my $module = shift;

    my $output;

    unless ($module) {
        return 'A module name is required';
    }

    my $full_name = "Metal::Module::${module}";

    if ($full_name eq __PACKAGE__) {
        return 'You cannot unload this module';
    }

    # Make sure the module is actually loaded...
    my $existing_modules = $self->bot->loaded_modules;
    my $requested_module = $existing_modules->{$full_name};

    unless ($requested_module) {
        return 'That module is not loaded';
    }

    $output = "Unloading ${full_name}";

    $requested_module->DEMOLISH();

    Class::Unload->unload($module);
    delete $existing_modules->{$full_name};

    $self->bot->loaded_modules($existing_modules);

    return $output;
}
=cut

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;
__END__

=head1 NAME

Metal::Module::ModuleManagement

=head1 DESCRIPTION

Commands related to management and listing of the bot's loaded modules.

=head2 METHODS

=over 4

=item C<on_bot_public()>

Runs on every public message the bot sees, potentially triggering a command.

=back

