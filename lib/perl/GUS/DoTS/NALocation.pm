package GUS::DoTS::NALocation;
use base qw(GUSRow);

use strict;



sub init {
    my ($self, $feature, $gusParentFeature) = @_;

    return {na_feature_id => $gusParentFeature->getPrimaryKey(),
	    start_min => $feature->start(),
	    start_max => $feature->start(),
	    end_min => $feature->end(),
	    end_max => $feature->end(),
	    is_reversed => $feature->strand() == -1 ? 1 : 0,
    };
}

1;

package GUS::DoTS::NALocation::Transcript;

sub init {
    my ($self, $gusParentFeature, $gusSplicedNASequence) = @_;

    return {na_feature_id => $gusParentFeature->getPrimaryKey(),
	    start_min => 1,
	    start_max => 1,
	    end_min => $gusSplicedNASequence->{length},
	    end_max => $gusSplicedNASequence->{length},
	    is_reversed => $gusParentFeature->{is_reversed},
    };
}


1;
