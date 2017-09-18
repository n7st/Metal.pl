use utf8;
package Metal::Schema::Result::Festival;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Metal::Schema::Result::Festival

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<festival>

=cut

__PACKAGE__->table("festival");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 date_created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 date_modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 created_by

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 modified_by

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "date_created",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "date_modified",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "created_by",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "modified_by",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 created_by

Type: belongs_to

Related object: L<Metal::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "created_by",
  "Metal::Schema::Result::User",
  { id => "created_by" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 modified_by

Type: belongs_to

Related object: L<Metal::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "modified_by",
  "Metal::Schema::Result::User",
  { id => "modified_by" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 user_festivals

Type: has_many

Related object: L<Metal::Schema::Result::UserFestival>

=cut

__PACKAGE__->has_many(
  "user_festivals",
  "Metal::Schema::Result::UserFestival",
  { "foreign.festival_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2016-08-24 17:52:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rc2gatIoBqksXEZcD+9u/Q

use DateTime;

sub insert {
    my $self = shift;

    my $now = DateTime->now();

    $self->date_created($now);
    $self->date_modified($now);

    return $self->next::method(@_);
}

1;
