package GUS::DoTS::AASequenceEnzymeClass;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $gusAASequenceId, $gusEnzymeClassId, $evidenceCode) = @_;

    return {aa_sequence_id => $gusAASequenceId,
	    enzyme_class_id => $gusEnzymeClassId,
	    evidence_code => $evidenceCode,
    };
}

1;
