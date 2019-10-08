package GUS::DoTS::ExternalNASequence;
use base qw(GUSRow);

use strict;
use Bio::Tools::SeqStats;
use Bio::Tools::SeqStats;
use Bio::PrimarySeq;

sub init {
    my ($self, $slice) = @_;

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
    return {na_sequence_id => $slice->get_seq_region_id(),
	    sequence_version => 1,
	    subclass_view => 'ExternalNASequence',
	    sequence =>  $seq,
	    length => $slice->seq_region_length(),
	    a_count => $monomersHash->{A},
	    c_count => $monomersHash->{C},
	    t_count => $monomersHash->{T},
	    g_count => $monomersHash->{G},
	    other_count => $otherCount,
	    source_id => $slice->seq_region_name(),

	    #chromosome => TODO,
	    #chromosome_order_num => TODO
	    #sequence_ontology_id => TODO,
	    #taxon_id => TODO,    
	    # external_database_release_id => todo,
    };
}

1;
