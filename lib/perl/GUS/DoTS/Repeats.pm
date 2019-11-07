package GUS::DoTS::Repeats;
use base qw(GUSRow);

use strict;


sub init {
    my ($self, $repeat, $gusExternalNASequence, $gusExternalDatabaseRelease) = @_;

    return {na_sequence_id => $gusExternalNASequence->getPrimaryKey(),
	    subclass_view => 'Repeats',
	    name => $repeat->analysis()->logic_name(),
	    external_database_release_id => $gusExternalDatabaseRelease->getPrimaryKey(),
	    source_id => $repeat->display_id(),
    };
}


1;
