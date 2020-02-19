package GUS::DoTS::DomainFeature;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $gusTranslatedAASequence, $parent, $externalDatabaseReleaseId, $sourceId, $evalue) = @_;

    return {aa_sequence_id => $gusTranslatedAASequence->getPrimaryKey(),
	    parent_id => $parent ? $parent->getPrimaryKey() : undef, 
	    external_database_release_id => $externalDatabaseReleaseId,
	    source_id => $sourceId,
	    e_value => $evalue,
	    is_predicted => 1,
	    subclass_view => 'DomainFeature',
    }
}

1;
