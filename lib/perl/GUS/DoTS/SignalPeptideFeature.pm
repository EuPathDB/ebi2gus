package GUS::DoTS::SignalPeptideFeature;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $gusTranslatedAASequence) = @_;

    return {aa_sequence_id => $gusTranslatedAASequence->getPrimaryKey(),
	    subclass_view => 'SignalPeptideFeature',
	    is_predicted => 0,
    };
}


1;
