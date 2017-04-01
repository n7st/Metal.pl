package Metal::Handler::Role::Module;

use Moose::Role;
use Try::Tiny;

with qw/
    Metal::Role::Config
    Metal::Role::Logger
/;

################################################################################

has mods_available => (is => 'ro', isa => 'ArrayRef[Str]',    lazy_build => 1);
has mods_enabled   => (is => 'ro', isa => 'ArrayRef[Object]', lazy_build => 1);

################################################################################

sub _handle_command {
    my $self = shift;
    my $type = shift; # PUBLIC, PRIVATE, NOTICE
    my $poe  = shift;
    my $args = shift;

    my $function = 'privmsg';
    my $location;

    if ($type eq 'PUBLIC') {
        $location = $args->{location};
    } elsif ($type =~ /(PRIVATE|NOTICE)/) {
        $location = $args->{from}->{nick};
    }

    $function = 'notice' if $type eq 'NOTICE';

    foreach my $mod (@{$self->mods_enabled}) {
        my (@actions, @output);

        try {
            $mod->reset();
            $mod->all($args, $poe);

            push @output,  @{$mod->{reply}};
        } catch {
            $self->logger->warn($_);
        } finally {
            if ($location) {
                foreach my $line (@output) {
                    $poe->{kernel}->post($poe->{heap}->{irc}, $function, $location, $line);
                }
            }
        };
    }

    return 1;
}

################################################################################

sub _build_mods_available {
    my $self = shift;

    return $self->config->{modules} // [];
}

sub _build_mods_enabled {
    my $self = shift;

    my @mods_enabled;

    foreach (@{$self->mods_available}) {
        my $module = 'Metal::Module::'.$_;

        eval "require $module";

        my $m = eval { $module->new() };
        if ($@) {
            $self->logger->warn($@);
        } else {
            push @mods_enabled, $m;
        }
    }

    return \@mods_enabled;
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Handler::Role::Module

=head1 DESCRIPTION

Map text commands to their relevant module for handling.

=head2 METHODS

=over 4

=item C<_handle_command()>

Try to find a relevant module to handle a sent command.

=item C<_build_mods_available()>

Static list of available modules.

=item C<_build_mods_enabled()>

Return an ArrayRef of bundled modules.

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

