package GUS::ApiDB::SeqEdit;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $seqEdit, $sequenceType, $sequenceOntologyId, $sourceId) = @_;
    
    return {source_id => $sourceId,
	    sequence_type => $sequenceType,
	    sequence_ontology_id => $sequenceOntologyId,
	    start_min => $seqEdit->start(),
	    end_exit => $seqEdit->end(),
	    sequence => $seqEdit->alt_seq(),
    };
}

1;
