package GUS::DoTS::NALocation;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $feature) = @_;

    return {na_location_id => $self->nextPk(),
	    na_feature_id => $feature->dbID(),
	    start_min => $feature->start(),
	    start_max => $feature->start(),
	    end_min => $feature->end(),
	    end_max => $feature->end(),
	    is_reversed => $feature->strand() == -1 ? 1 : 0,
    };
}

1;
