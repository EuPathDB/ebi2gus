package GUS::ApiDB::AaSequenceAttribute;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $translation, $gusTranslatedAASequence) = @_;

    my $molWeight = $translation->get_all_Attributes("MolecularWeight")->[0]->value();
    
    return {aa_sequence_id => $gusTranslatedAASequence->getPrimaryKey(),
	    min_molecular_weight => $molWeight,
	    max_molecular_weight => $molWeight,
	    isoelectric_point => $translation->get_all_Attributes("IsoPoint")->[0]->value(),	    
    };
}

1;
