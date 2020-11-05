package GUS::DoTS::Transcript;
use base qw(GUSRow);

use strict;

sub init {
    my ($self,  $transcript, $gusGeneFeature, $gusSplicedNASequence, $gusExternalDatabaseRelease, $transcriptSequenceOntologyId) = @_;
              
    my $naSequenceId = $gusSplicedNASequence->getPrimaryKey();

    my $isPseudo = $transcript->get_Biotype()->name() =~ /pseudogen/ ? 1 : 0;
    
    return {subclass_view => "Transcript",
	    na_sequence_id => $gusSplicedNASequence->getPrimaryKey(),
	    name => "transcript",
	    sequence_ontology_id => $transcriptSequenceOntologyId,
	    parent_id => $gusGeneFeature->getPrimaryKey(),
	    external_database_release_id => $gusExternalDatabaseRelease->getPrimaryKey(),
	    source_id => $transcript->stable_id(),
	    product => $transcript->description(),
	    is_pseudo => $isPseudo,
};
}

1;
