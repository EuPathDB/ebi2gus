package GUS::DoTS::ExternalNASequence;
use base qw(GUSRow);

use strict;

use Bio::Tools::SeqStats;
use Bio::PrimarySeq;


sub init {
    my ($self, $slice, $gusTaxon, $gusExternalDatabaseRelease, $gusSequenceOntologyId, $sequenceSourceId) = @_;

    my $organism = $gusTaxon->getOrganism();
    my $chromosomeMap = $organism->getChromosomeMap();
    
    my $seq = $slice->seq();
    my $primarySeq = Bio::PrimarySeq->new(-seq=>$seq,
					  -alphabet=>'dna');

    my $seqStats  =  Bio::Tools::SeqStats->new(-seq=>$primarySeq);
    my $monomersHash = $seqStats->count_monomers();

    my $otherCount;
    foreach my $m (keys %$monomersHash) {
	next if $m eq 'A' || $m eq 'C' || $m eq 'T' || $m eq 'G';
	$otherCount = $otherCount + $monomersHash->{$m}
    }

    return {sequence_version => 1,
	    subclass_view => 'ExternalNASequence',
	    sequence =>  $seq,
	    length => $slice->seq_region_length(),
	    a_count => $monomersHash->{A},
	    c_count => $monomersHash->{C},
	    t_count => $monomersHash->{T},
	    g_count => $monomersHash->{G},
	    other_count => $otherCount,
	    source_id => $sequenceSourceId,
	    name => $slice->seq_region_name(),
	    taxon_id => $gusTaxon->getPrimaryKey(),
	    external_database_release_id => $gusExternalDatabaseRelease->getPrimaryKey(),
	    chromosome => $chromosomeMap->{$sequenceSourceId}->{chromosome},
	    chromosome_order_num => $chromosomeMap->{$sequenceSourceId}->{chromosome_order_num},
	    sequence_ontology_id => $gusSequenceOntologyId
    };
}

1;
