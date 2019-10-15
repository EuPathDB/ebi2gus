package GUS::DoTS::GeneFeature;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $gene, $gusExternalNASequence, $gusExternalDatabaseRelease) = @_;

# TODO:  Sequence Ontology must first be made. then we can use its primarykey
# can't simply use the dbID()
    
    return {na_sequence_id => $gusExternalNASequence->getPrimaryKey(),
	    subclass_view => 'GeneFeature',
	    name => $gene->get_Biotype()->name(),
#	    sequence_ontology_id => $gene->get_Biotype()->dbID(),
	    external_database_release_id => $gusExternalDatabaseRelease->getPrimaryKey(),
	    source_id => $gene->stable_id(),
    };
}

1;
