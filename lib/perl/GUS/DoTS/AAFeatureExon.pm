package GUS::DoTS::AAFeatureExon;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $gusTranslatedAAFeature, $gusExonId, $codingRegionStart, $codingRegionEnd) = @_;

    return {exon_feature_id => $gusExonId,
	    aa_feature_id => $gusTranslatedAAFeature->getPrimaryKey(),
	    coding_start => $codingRegionStart,
	    coding_end => $codingRegionEnd
    };
    
}

1;
