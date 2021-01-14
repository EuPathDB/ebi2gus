package GUS::DoTS::Miscellaneous;
use base qw(GUSRow);

use strict;


sub init {
    my ($self, $name, $gusExternalNASequence, $gusExternalDatabaseRelease, $sequenceOntologyId) = @_;

    print "IN INIT\n";
    
    return {na_sequence_id => $gusExternalNASequence->getPrimaryKey(),
	    subclass_view => 'Miscellaneous',
	    name => $name,
	    source_id => $name,
	    sequence_ontology_id => $sequenceOntologyId,
	    external_database_release_id => $gusExternalDatabaseRelease->getPrimaryKey(),
    };
}

1;
