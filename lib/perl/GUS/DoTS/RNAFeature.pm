package GUS::DoTS::RNAFeature;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $rnaFeature, $gusNASequence, $externalDatabaseReleaseId, $sequenceOntologyId) = @_;
              
    my $naSequenceId = $gusNASequence->getPrimaryKey();

    my $sourceId =  $rnaFeature->display_id() . "_" . $rnaFeature->seq_region_name() . "_" . $rnaFeature->seq_region_start() . "_" . $rnaFeature->seq_region_end();
    
    return {subclass_view => "RNAFeature",
	    na_sequence_id => $naSequenceId,
	    name => "rna_feature",
	    sequence_ontology_id => $sequenceOntologyId,
	    external_database_release_id => $externalDatabaseReleaseId,
	    source_id => $sourceId,
    };
}

1;

