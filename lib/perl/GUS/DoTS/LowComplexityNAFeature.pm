package GUS::DoTS::LowComplexityNAFeature;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $repeat, $gusExternalNASequence, $gusExternalDatabaseRelease) = @_;

    return {na_sequence_id => $gusExternalNASequence->getPrimaryKey(),
	    subclass_view => 'LowComplexityNAFeature',
	    name => $repeat->analysis()->logic_name(),
	    external_database_release_id => $gusExternalDatabaseRelease->getPrimaryKey(),
	    source_id => $gusExternalNASequence->getGUSRowAsHash()->{source_id},
	    is_predicted => 1,
    };
}


1;
