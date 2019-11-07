package GUS::DoTS::DbRefAAFeature;
use base qw(GUSRow);

use strict;

sub init {
    my ($gusDbRefId, $gusAAFeatureId) = @_;

    return {db_ref_id => $gusDbRefId,
	    aa_feature_id => $gusAAFeatureId,
    };

}

1;
