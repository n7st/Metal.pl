package Metal::Module::Role::Blockable;

use Moose::Role;

################################################################################

has unloaded => (is => 'rw', isa => 'Bool', default => 0);

around [ qw(on_bot_public) ] => sub {
    my $orig = shift;
    my $self = shift;

    return if $self->unloaded;
    return $self->$orig(@_);
};

################################################################################

no Moose;
1;
