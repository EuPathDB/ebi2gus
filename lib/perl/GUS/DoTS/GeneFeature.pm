package GUS::DoTS::GeneFeature;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $gene, $slice) = @_;

    return {na_feature_id => $gene->dbID(),
	    na_sequence_id => $slice->get_seq_region_id(),
	    subclass_view => 'GeneFeature',
	    name => $gene->get_Biotype()->name(),
	    sequenc_ontology_id => $gene->get_Biotype()->dbID(),
	    #external_database_release_id => TODO
	    source_id => $gene->stable_id(),
    };
}

1;
