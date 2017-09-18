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

=head2 lastfm

  data_type: 'varchar'
  is_nullable: 1
  size: 20

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
  "lastfm",
  { data_type => "varchar", is_nullable => 1, size => 20 },
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

=head2 events_created_by

Type: has_many

Related object: L<Metal::Schema::Result::Event>

=cut

__PACKAGE__->has_many(
  "events_created_by",
  "Metal::Schema::Result::Event",
  { "foreign.created_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 events_modified_by

Type: has_many

Related object: L<Metal::Schema::Result::Event>

=cut

__PACKAGE__->has_many(
  "events_modified_by",
  "Metal::Schema::Result::Event",
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

=head2 permissions_created_by

Type: has_many

Related object: L<Metal::Schema::Result::Permission>

=cut

__PACKAGE__->has_many(
  "permissions_created_by",
  "Metal::Schema::Result::Permission",
  { "foreign.created_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 permissions_modified_by

Type: has_many

Related object: L<Metal::Schema::Result::Permission>

=cut

__PACKAGE__->has_many(
  "permissions_modified_by",
  "Metal::Schema::Result::Permission",
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

=head2 user_permission_users

Type: has_many

Related object: L<Metal::Schema::Result::UserPermission>

=cut

__PACKAGE__->has_many(
  "user_permission_users",
  "Metal::Schema::Result::UserPermission",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_permissions_created_by

Type: has_many

Related object: L<Metal::Schema::Result::UserPermission>

=cut

__PACKAGE__->has_many(
  "user_permissions_created_by",
  "Metal::Schema::Result::UserPermission",
  { "foreign.created_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_permissions_modified_by

Type: has_many

Related object: L<Metal::Schema::Result::UserPermission>

=cut

__PACKAGE__->has_many(
  "user_permissions_modified_by",
  "Metal::Schema::Result::UserPermission",
  { "foreign.modified_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-11-28 22:23:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sFu6RrnULtGi5+gq0AzRJg

use Data::Printer;
use DateTime;

sub all_permissions {
    my $self = shift;

    my @permissions      = $self->user_permission_users->all();
    my %user_permissions = map { $_->permission->name => 1 } @permissions;

    return \%user_permissions;
}

sub has_permission {
    my $self = shift;
    my $name = shift;

    my $permissions = $self->all_permissions();

    return $permissions->{$name};
}

sub insert {
    my $self = shift;

    my $now = DateTime->now();

    $self->date_created($now);
    $self->date_modified($now);

    return $self->next::method(@_);
}

1;

