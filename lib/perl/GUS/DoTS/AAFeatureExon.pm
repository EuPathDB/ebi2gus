package GUS::DoTS::AAFeatureExon;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $exon, $gusTranslatedAAFeature, $gusExonId) = @_;

    return {exon_feature_id => $gusExonId,
	    aa_feature_id => $gusTranslatedAAFeature->getPrimaryKey(),
	    coding_start => $exon->coding_region_start(),
	    coding_end => $exon->coding_region_end(),
    };
    
}

1;
