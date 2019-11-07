package GUS::DoTS::AALocation;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $feature, $gusFeature) = @_;

    return {aa_feature_id => $gusFeature->getPrimaryKey(),
	    start_min => $feature->start(),
	    start_max => $feature->start(),
	    end_min => $feature->end(),
	    end_max => $feature->end(),
    };
}

1;
