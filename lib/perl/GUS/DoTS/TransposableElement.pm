package GUS::DoTS::TransposableElement;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $repeat, $gusExternalNASequence, $gusExternalDatabaseRelease) = @_;

    return {na_sequence_id => $gusExternalNASequence->getPrimaryKey(),
	    subclass_view => 'TransposableElement',
	    name => $repeat->analysis()->logic_name(),
	    external_database_release_id => $gusExternalDatabaseRelease->getPrimaryKey(),
	    source_id => $repeat->display_id(),
	    # sequence_ontology_id => ?? ebi doesn't have this; we dont use it skipping....
    };
}


1;
