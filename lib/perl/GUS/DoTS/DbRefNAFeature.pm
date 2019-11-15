package GUS::DoTS::DbRefNAFeature;
use base qw(GUSRow);

use strict;

sub init {
    my ($gusDbRefId, $gusNAFeatureId) = @_;

    return {db_ref_id => $gusDbRefId,
	    na_feature_id => $gusNAFeatureId,
    };
}

1;
