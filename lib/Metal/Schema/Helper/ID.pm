package Metal::Schema::Helper::ID;

use strict;
use warnings;

use base 'DBIx::Class';

use Class::C3::Componentised::ApplyHooks -after_apply => sub {
    my $class = shift;

    $class->add_columns(
        'id',
        {
            data_type         => 'integer',
            extra             => { unsigned => 1 },
            is_auto_increment => 1,
            is_nullable       => 0,
        },
    );

    return $class->set_primary_key('id');
};

1;
__END__

=head1 NAME

Metal::Schema::Helper::ID

=head1 DESCRIPTION

Adds an unsigned integer primary key to a result object.

=head2 USAGE

    __PACKAGE__->load_components('+Metal::Schema::Helper::ID');

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

