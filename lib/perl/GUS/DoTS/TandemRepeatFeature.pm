package GUS::DoTS::TandemRepeatFeature;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $repeat, $gusExternalNASequence, $gusExternalDatabaseRelease) = @_;

    return {na_sequence_id => $gusExternalNASequence->getPrimaryKey(),
	    subclass_view => 'TandemRepeatFeature',
	    name => $repeat->analysis()->logic_name(),
	    external_database_release_id => $gusExternalDatabaseRelease->getPrimaryKey(),
	    source_id => $gusExternalNASequence->{source_id},
    };
}

1;
