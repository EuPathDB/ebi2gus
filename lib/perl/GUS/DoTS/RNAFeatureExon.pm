package GUS::DoTS::RNAFeatureExon;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $gusExonId, $gusTranscript, $exonOrderNum) = @_;

    
    return {rna_feature_id => $gusTranscript->getPrimaryKey(),
	    order_number => $exonOrderNum,
	    exon_feature_id => $gusExonId
    };
}

1;
