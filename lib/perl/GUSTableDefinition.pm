package GUSTableDefinition;

use strict;

sub getName { $_[0]->{_name} }
sub setName { $_[0]->{_name} = $_[1] }

sub getRealTableName { $_[0]->{_real_table_name} }
sub setRealTableName { $_[0]->{_real_table_name} = $_[1] }

sub getFields { $_[0]->{_fields} }
sub setFields { $_[0]->{_fields} = $_[1] }

sub getFieldDataTypes { $_[0]->{_field_datatypes} }
sub setFieldDataTypes { $_[0]->{_field_datatypes} = $_[1] }

sub getPrimaryKey  { $_[0]->{_primary_key} }
sub setPrimaryKey  { $_[0]->{_primary_key} = $_[1] }

sub getNonNullFields { $_[0]->{_non_null_fields} }
sub setNonNullFields { $_[0]->{_non_null_fields} = $_[1] }

sub getParentRelations { $_[0]->{_parent_relations} }
sub setParentRelations { $_[0]->{_parent_relations} = $_[1] }

sub isView { $_[0]->{_is_view} }

sub getViewToImpFieldMap { $_[0]->{_view_to_imp_field_map} }
sub setViewToImpFieldMap { $_[0]->{_view_to_imp_field_map} = $_[1] }

sub new {
    my ($class, $xml) = @_;

    my $self = bless {}, $class;

    #TODO:  USE XML hash to set instance variables

    return $self; 
}


1;
