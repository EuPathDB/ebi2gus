package GUSTableDefinition;

use strict;

sub getName { $_[0]->{_name} }
sub setName { $_[0]->{_name} = $_[1] }

sub getRealTableName { $_[0]->{_real_table_name} }
sub setRealTableName { $_[0]->{_real_table_name} = uc($_[1]) }

sub getFields { $_[0]->{_fields} }
sub setFields { $_[0]->{_fields} = $_[1] }

sub getFieldDataTypes { $_[0]->{_field_datatypes} }
sub setFieldDataTypes { $_[0]->{_field_datatypes} = $_[1] }

sub getPrimaryKeyField  { $_[0]->{_primary_key_field} }
sub setPrimaryKeyField  { $_[0]->{_primary_key_field} = lc $_[1] }

sub getNonNullFields { $_[0]->{_non_null_fields} }
sub setNonNullFields { $_[0]->{_non_null_fields} = $_[1] }

# TODO:  not sure these are needed??
#sub getParentRelations { $_[0]->{_parent_relations} }
#sub setParentRelations { $_[0]->{_parent_relations} = $_[1] }

sub isView { $_[0]->{_is_view} }

sub getViewToImpFieldMap { $_[0]->{_view_to_imp_field_map} }
sub setViewToImpFieldMap { $_[0]->{_view_to_imp_field_map} = $_[1] }

sub getImpToViewFieldMap { $_[0]->{_imp_to_view_field_map} }
sub setImpToViewFieldMap { $_[0]->{_imp_to_view_field_map} = $_[1] }


sub new {
    my ($class, $tableName, $tableHash) = @_;

    my $self = bless {}, $class;

    $self->setName($tableName);

    if(my $impTable = $tableHash->{impTable}) {
	$self->setRealTableName($impTable);
	$self->{_is_view} = 1;
	my %viewToImpFieldMap = map { lc $_ => lc $tableHash->{column}->{$_}->{impColumn} || lc $_  } keys %{$tableHash->{column}};

	my %impToViewFieldMap = map { lc $tableHash->{column}->{$_}->{impColumn} || lc $_ => lc $_  } keys %{$tableHash->{column}};

	$self->setViewToImpFieldMap(\%viewToImpFieldMap);
	$self->setImpToViewFieldMap(\%impToViewFieldMap);
    }
    else {
	$self->setRealTableName($tableName);
    }


    my (@fields, %fieldDataTypes);
    foreach my $field (keys %{$tableHash->{column}}) {
	$field = lc $field;
	push @fields, $field;

	my $type = $tableHash->{column}->{$field}->{type};
	my $length = $tableHash->{column}->{$field}->{length};
	$fieldDataTypes{$field} = {type => $type, length => $length};
    }
    $self->setFieldDataTypes(\%fieldDataTypes);
    $self->setFields(\@fields);
    $self->setPrimaryKeyField(lc $tableHash->{primaryKey});

    return $self; 
}


1;
