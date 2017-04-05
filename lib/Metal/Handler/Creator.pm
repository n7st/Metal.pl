package Metal::Handler::Creator;

use Moose;

with 'Metal::Role::Logger';

use constant {
    BASE_DIR => "lib/Metal/Handler/",
};

################################################################################

has type => (is => 'ro', isa => 'Maybe[Str]');

has name => (is => 'ro', isa => 'Str', required => 1);

has directory  => (is => 'ro', isa => 'Str', lazy_build => 1);
has filename   => (is => 'ro', isa => 'Str', lazy_build => 1);
has template   => (is => 'ro', isa => 'Str', lazy_build => 1);
has type_block => (is => 'ro', isa => 'Str', lazy_build => 1);

################################################################################

sub generate {
    my $self = shift;

    $self->logger->info("Creating directory ".$self->directory);

    system("mkdir -p ".$self->directory);

    $self->logger->info("Creating file ".$self->filename);

    system("touch ".$self->filename);

    unless (open FILE, '>', $self->filename) {
        $self->logger->warn("Missing file: ".$self->filename);

        return 0;
    }

    print FILE $self->template;
    close FILE;

    return 1;
}

################################################################################

sub _build_directory {
    my $self = shift;

    my @file_struct = split /::/, $self->name;
    my $filename    = pop @file_struct;

    return sprintf("%s%s", $self->BASE_DIR, join('/', @file_struct));
}

sub _build_filename {
    my $self = shift;

    my @file_struct = split /::/, $self->name;
    my $filename    = pop @file_struct;

    return sprintf("%s/%s.pm", $self->directory, $filename);
}

sub _build_type_block {
    my $self = shift;

    if ($self->type) {
        return "\n\nsub _build_type { '$self->type' }";
    }

    return '';
}

sub _build_template {
    my $self = shift;

    my $name       = $self->name;
    my $type_block = $self->type_block;

    my $template = <<"DEFAULT";
package Metal::Handler::$name;

use Moose;

extends 'Metal::Handler';

################################################################################

sub irc_999 {
    my \$self    = shift;
    my \$session = shift;
    my \$kernel  = shift;
    my \$heap    = shift;

    return 1;
}

################################################################################

sub _build_events {
    return {
        irc_999 => 1,
    };
}$type_block

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Handler::$name

=head1 DESCRIPTION

=head2 METHODS

=over 4

=item C<_build_events()>

Build a list of events handled by this package to be read in the program's
main package.

=back

DEFAULT

    return $template;
}

################################################################################

no Moose;
__PACKAGE__->meta->make_immutable();
1;
__END__

=head1 NAME

Metal::Handler::New

=head1 DESCRIPTION

Generate a new handler for the framework.

=head2 SYNOPSIS

    use Metal::Handler::New;

    my $nh = Metal::Handler::Creator->new({
        name => 'Internal::My::New::Handler',
    });

    $nh->generate();

=head2 METHODS

=over 4

=item C<generate()>

Create a new handler.

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

