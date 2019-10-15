package GUS::DoTS::TranslatedAASequence;
use base qw(GUSRow);

use strict;

use Data::Dumper;

sub init {
    my ($self, $transcript, $taxonId) = @_;

    my $translation = $transcript->translation();

    return {sequence_version => 1,
            subclass_view => "TranslatedAASequence",
	    molecular_weight => $translation->get_all_Attributes("MolecularWeight")->[0]->value(),
	    sequence => $translation->seq(),
	    source_id => $translation->summary_as_hash->{protein_id}, # can't find the protein id in this object for some reason??
	    length => $translation->length(),
	    taxon_id => $taxonId,

#	    #sequence_ontology_id => TODO:  based on the coordsystem, populate this with new ontology term for chromosome,scaffold, contig, ...
	    # external_database_release_id => TODO:  Same issue as GeneFeature

	    
    };
}

1;
