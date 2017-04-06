package Metal::Schema::Helper::DateFields;

use strict;
use warnings;

use base 'DBIx::Class';

use DateTime;
use Class::C3::Componentised::ApplyHooks -after_apply => sub {
    my $class     = shift;
    my $component = shift;

    $class->add_columns(
        date_created => {
            data_type                 => 'datetime',
            datetime_undef_if_invalid => 1,
            is_nullable               => 0,
            locale                    => 'en_GB',
            timezone                  => 'local',
        },
        date_modified => {
            data_type                 => 'datetime',
            datetime_undef_if_invalid => 1,
            is_nullable               => 0,
            locale                    => 'en_GB',
            timezone                  => 'local',
        },
    );
};

sub insert {
    my $self = shift;

    my $now = DateTime->now(time_zone => 'local');

    $self->date_created($now);
    $self->date_modified($now);

    return $self->next::method(@_);
}

sub update {
    my $self = shift;

    $self->date_modified(DateTime->now(time_zone => 'local'));

    return $self->next::method(@_);
}

1;

