package GUS::DoTS::GeneFeature;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $gene, $gusExternalNASequence, $gusExternalDatabaseRelease, $geneSequenceOntologyId) = @_;

    return {na_sequence_id => $gusExternalNASequence->getPrimaryKey(),
	    subclass_view => 'GeneFeature',
	    name => $gene->get_Biotype()->name(),
	    sequence_ontology_id => $geneSequenceOntologyId,
	    external_database_release_id => $gusExternalDatabaseRelease->getPrimaryKey(),
	    source_id => $gene->stable_id(),
	    product => $gene->description(),
    };
}

1;
