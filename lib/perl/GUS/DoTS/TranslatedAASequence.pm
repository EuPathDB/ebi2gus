package GUS::DoTS::TranslatedAASequence;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $transcript, $taxonId, $gusExternalDatabaseRelease, $translatedAASequenceOntologyId) = @_;

    my $translation = $transcript->translation();

    return {sequence_version => 1,
            subclass_view => "TranslatedAASequence",
	    molecular_weight => $translation->get_all_Attributes("MolecularWeight")->[0]->value(),
	    sequence => $translation->seq(),
            source_id => $translation->stable_id(),
	    length => $translation->length(),
	    taxon_id => $taxonId,
	    sequence_ontology_id => $translatedAASequenceOntologyId,
	    external_database_release_id => $gusExternalDatabaseRelease->getPrimaryKey(),
    };
}

1;
