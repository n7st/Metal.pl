use utf8;
package Metal::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Metal::Schema::Result::User

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 hostmask

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 date_created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 date_modified

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "hostmask",
  { data_type => "varchar", is_nullable => 0, size => 100 },
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
  "name",
  { data_type => "varchar", is_nullable => 0, size => 45 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 bands_created_by

Type: has_many

Related object: L<Metal::Schema::Result::Band>

=cut

__PACKAGE__->has_many(
  "bands_created_by",
  "Metal::Schema::Result::Band",
  { "foreign.created_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bands_modified_by

Type: has_many

Related object: L<Metal::Schema::Result::Band>

=cut

__PACKAGE__->has_many(
  "bands_modified_by",
  "Metal::Schema::Result::Band",
  { "foreign.modified_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 festivals_created_by

Type: has_many

Related object: L<Metal::Schema::Result::Festival>

=cut

__PACKAGE__->has_many(
  "festivals_created_by",
  "Metal::Schema::Result::Festival",
  { "foreign.created_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 festivals_modified_by

Type: has_many

Related object: L<Metal::Schema::Result::Festival>

=cut

__PACKAGE__->has_many(
  "festivals_modified_by",
  "Metal::Schema::Result::Festival",
  { "foreign.modified_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pizzas

Type: has_many

Related object: L<Metal::Schema::Result::Pizza>

=cut

__PACKAGE__->has_many(
  "pizzas",
  "Metal::Schema::Result::Pizza",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_bands

Type: has_many

Related object: L<Metal::Schema::Result::UserBand>

=cut

__PACKAGE__->has_many(
  "user_bands",
  "Metal::Schema::Result::UserBand",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_festivals

Type: has_many

Related object: L<Metal::Schema::Result::UserFestival>

=cut

__PACKAGE__->has_many(
  "user_festivals",
  "Metal::Schema::Result::UserFestival",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2016-08-24 17:52:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hcikdtsh5ymNBGHrOBlTGQ

use DateTime;

sub insert {
    my $self = shift;

    my $now = DateTime->now();

    $self->date_created($now);
    $self->date_modified($now);

    return $self->next::method(@_);
}

1;
