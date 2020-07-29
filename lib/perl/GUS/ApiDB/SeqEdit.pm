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

    my $originalSequence = $self->getInitialSequence($seqEdit, $transcript, $sequenceType);

    return {source_id => $sourceId,
	    sequence_type => $sequenceType,
	    sequence_ontology_id => $sequenceOntologyId,
	    trans_start => $seqEdit->start(), 
	    trans_end => $seqEdit->end(), 
	    sequence => $seqEdit->alt_seq(),
	    orig_sequence => $originalSequence, 
	    start_min => $coord->start(),
	    end_max => $coord->end(),
	    length_diff => $seqEdit->length_diff(),
    };
}

sub getInitialSequence {
    my ($self, $seqEdit, $transcript, $sequenceType) = @_;

    # turn off edits
    $transcript->edits_enabled(0);

    my $sequence;
    if($sequenceType eq 'translation') {
	$sequence = $transcript->translate()->seq();
    }
    elsif($sequenceType eq 'translation') {
	$sequence = $transcript->spliced_seq();
    }
    else {
	die "only transcript or translation seqedit types are supported";
    }

    my $len = $seqEdit->end() - $seqEdit->start() + 1;
    my $substr = substr($sequence, $seqEdit->start - 1, $len);

    # turn back on edits!
    $transcript->edits_enabled(1);
    
    return $substr;
}

1;
