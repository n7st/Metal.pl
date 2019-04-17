package Metal::Schema::Helper::DateFields;

use strict;
use warnings;

use base 'DBIx::Class';

use constant DEFAULT_TZ => 'UTC';

use DateTime;
use Class::C3::Componentised::ApplyHooks -after_apply => sub {
    my $class     = shift;
    my $component = shift;

    $class->add_columns(
        'date_created',
        {
            data_type                 => 'datetime',
            datetime_undef_if_invalid => 1,
            is_nullable               => 0,
            locale                    => 'en_GB',
            timezone                  => DEFAULT_TZ,
        },
        'date_modified',
        {
            data_type                 => 'datetime',
            datetime_undef_if_invalid => 1,
            is_nullable               => 0,
            locale                    => 'en_GB',
            timezone                  => DEFAULT_TZ,
        },
    );
};

################################################################################

sub insert {
    my $self = shift;

    my $now = DateTime->now(time_zone => DEFAULT_TZ);

    $self->date_created($now);
    $self->date_modified($now);

    return $self->next::method(@_);
}

sub update {
    my $self = shift;

    $self->date_modified(DateTime->now(time_zone => DEFAULT_TZ));

    return $self->next::method(@_);
}

################################################################################

1;
__END__

=head1 NAME

Metal::Schema::Helper::DateFields

=head1 DESCRIPTION

Adds DateTime fields to a schema result file.

=head2 CONSTANTS

=over 4

=item * C<DEFAULT_TZ>

The application should use UTC for consistency. Code elsewhere should refer to
this constant.

=back

=head2 METHODS

=over 4

=item * C<insert()>

Sets the C<date_created> and C<date_modified> fields to a timestamp of now.

=item * C<update()>

Sets the C<date_modified> field to a timestamp of now.

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

