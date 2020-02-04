package GUS::DoTS::DbRefNASequence;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $gusDbRefId, $gusNASequenceId) = @_;

    return {db_ref_id => $gusDbRefId,
	    na_sequence_id => $gusNASequenceId,
    };
}

1;

