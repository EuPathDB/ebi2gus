package GUS::DoTS::GeneFeature;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $gene, $gusExternalNASequence) = @_;

    return {na_sequence_id => $gusExternalNASequence->getPrimaryKey(),
	    subclass_view => 'GeneFeature',
	    name => $gene->get_Biotype()->name(),
	    sequence_ontology_id => $gene->get_Biotype()->dbID(),
	    #external_database_release_id => TODO
	    source_id => $gene->stable_id(),
    };
}

1;
