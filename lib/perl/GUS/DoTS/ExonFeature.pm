package GUS::DoTS::ExonFeature;
use base qw(GUSRow);

use strict;

use Data::Dumper;

sub init {
    my ($self, $exon, $gusGeneFeature, $gusExternalDatabaseRelease) = @_;

    return {na_sequence_id => $gusGeneFeature->{na_sequence_id},
	    subclass_view => 'ExonFeature',
	    name => 'exon',
#	    sequence_ontology_id => TODO
	    parent_id => $gusGeneFeature->getPrimaryKey(),
	    external_database_release_id => $gusExternalDatabaseRelease->getPrimaryKey(),
	    source_id => $exon->stable_id(),
    };
}

1;
