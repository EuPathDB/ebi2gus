package GUS::ApiDB::SeqEdit;
use base qw(GUSRow);

use strict;

use Bio::EnsEMBL::TranscriptMapper;

sub init {
    my ($self, $seqEdit, $sequenceType, $sequenceOntologyId, $transcript, $sourceId) = @_;

    my $mapper = Bio::EnsEMBL::TranscriptMapper->new($transcript);

    my $coord;
    if($sequenceType eq 'translation') {
	my @coords = $mapper->pep2genomic($seqEdit->start(), $seqEdit->end());
	$coord = $coords[0];
    }
    elsif($sequenceType eq 'transcript') {
	my @coords = $mapper->cdna2genomic($seqEdit->start(), $seqEdit->end());
	$coord = $coords[0];
    }
    else {
	die "only transcript or translation seqedit types are supported";
    }

    return {source_id => $sourceId,
	    sequence_type => $sequenceType,
	    sequence_ontology_id => $sequenceOntologyId,
	    trans_start => $seqEdit->start(),
	    trans_end => $seqEdit->end(),
	    sequence => $seqEdit->alt_seq(),
	    start_min => $coord->start(),
	    end_max => $coord->end(),
	    length_diff => $seqEdit->length_diff(),
    };
}

1;
