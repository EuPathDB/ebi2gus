package GUS::DoTS::TransMembraneAAFeature;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $gusTranslatedAASequence) = @_;

    return {aa_sequence_id => $gusTranslatedAASequence->getPrimaryKey(),
	    subclass_view => 'TransMembraneAAFeature',
	    is_predicted => 1,
    };
}

1;
