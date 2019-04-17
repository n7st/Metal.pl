package Metal::Schema::Helper::BelongingToUser;

use strict;
use warnings;

use base 'DBIx::Class';

use Class::C3::Componentised::ApplyHooks -after_apply => sub {
    my $class = shift;

    $class->add_columns(
        'user_id',
        {
            data_type   => 'integer',
            extra       => { unsigned => 1 },
            is_nullable => 0,
        },
    );

    return $class->belongs_to(
        user => 'Metal::Schema::Result::User',
        { 'foreign.id' => 'self.user_id' },
    );
};

1;
__END__

=head1 NAME

Metal::Schema::Helper::BelongingToUser

=head1 DESCRIPTION

Marks a result as belonging to a user by adding a C<user_id> column and setting
a relationship to the user object.

=head2 USAGE

    __PACKAGE__->load_components('+Metal::Schema::Helper::BelongingToUser');

=head1 SEE ALSO

=over 4

=item * L<Metal::Schema::Result::User>

The user object.

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

