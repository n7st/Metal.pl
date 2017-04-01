#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;

my $base = 'lib/Metal/Handler/';
my ($handler, $type);

Getopt::Long::GetOptions(
    'handler|h=s' => \$handler,
    'type|t=s'    => \$type,
);

die "No handler!" unless $handler;

my @dir_file_struct = split /::/, $handler;
my $filename        = pop @dir_file_struct;
my $directories     = join '/', @dir_file_struct;
my $dirs_with_base  = sprintf("%s%s", $base, $directories);

my $filename_with_dirs = sprintf("%s/%s.pm", $dirs_with_base, $filename);

if ($directories) {
    system("mkdir -p $dirs_with_base");
}

system("touch $filename_with_dirs");

unless (open FILE, '>', $filename_with_dirs) {
    die "Missing file!\n";
}

my $type_builder = $type ? "\n\nsub _build_type { '$type' }" : '';

my $def = <<"DEFAULT";
package Metal::Handler::$handler;

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
}$type_builder

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Handler::$handler

=head1 DESCRIPTION

=head2 METHODS

=over 4

=item C<_build_events()>

Build a list of events handled by this package to be read in the program's
main package.

=back

DEFAULT

print FILE $def;

exit 0;
__END__

=head1 NAME

script/dev/new_handler.pl

=head1 DESCRIPTION

Create a new Metal Handler class in a specified namespace with boilerplate POD
and base methods.

=head2 USAGE

    perl script/dev/new_handler -h Internal::New::Handler [-t SomeType]

Where 'Internal::New::Handler' is the new class you would like to create.

