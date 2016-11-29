use utf8;
package Metal::Schema::Result::UserPermission;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Metal::Schema::Result::UserPermission

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<user_permission>

=cut

__PACKAGE__->table("user_permission");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 permission_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
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
  "user_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "permission_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
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

=head2 permission

Type: belongs_to

Related object: L<Metal::Schema::Result::Permission>

=cut

__PACKAGE__->belongs_to(
  "permission",
  "Metal::Schema::Result::Permission",
  { id => "permission_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 user

Type: belongs_to

Related object: L<Metal::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Metal::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-11-28 22:23:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hJl5g9pvhurbH4SgO6aYWQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;