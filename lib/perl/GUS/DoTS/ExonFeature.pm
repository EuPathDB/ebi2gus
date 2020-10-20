package GUS::DoTS::ExonFeature;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $exonSourceId, $gusGeneFeature, $gusExternalDatabaseReleaseId, $exonSequenceOntologyId) = @_;

    return {na_sequence_id => $gusGeneFeature->getGUSRowAsHash()->{na_sequence_id},
	    subclass_view => 'ExonFeature',
	    name => 'exon',
	    sequence_ontology_id => $exonSequenceOntologyId,
	    parent_id => $gusGeneFeature->getPrimaryKey(),
	    external_database_release_id => $gusExternalDatabaseReleaseId,
	    source_id => $exonSourceId,
    };
}

1;
