package GUS::DoTS::LowComplexityAAFeature;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $gusTranslatedAASequence) = @_;

    return {aa_sequence_id => $gusTranslatedAASequence->getPrimaryKey(),
	    subclass_view => 'LowComplexityAAFeature',
	    is_predicted => 1,
    };
}

1;
