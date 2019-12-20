package GUS::DoTS::DbRefNAFeature;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $gusDbRefId, $gusNAFeatureId) = @_;

    return {db_ref_id => $gusDbRefId,
	    na_feature_id => $gusNAFeatureId,
    };
}

1;
