package GUS::DoTS::SplicedNASequence;
use base qw(GUSRow);

use strict;

use Bio::Tools::SeqStats;
use Bio::PrimarySeq;

sub init {
    my ($self, $transcript, $taxonId, $gusExternalDatabaseRelease, $splicedNASequenceOntologyId) = @_;

    my $seq = $transcript->spliced_seq();
    my $primarySeq = $transcript->seq();

    my $seqStats  =  Bio::Tools::SeqStats->new(-seq=>$primarySeq);
    my $monomersHash = $seqStats->count_monomers();

    my $otherCount;
    foreach my $m (keys %$monomersHash) {
	next if $m eq 'A' || $m eq 'C' || $m eq 'T' || $m eq 'G';
	$otherCount = $otherCount + $monomersHash->{$m}
    }
	
    return {sequence_version => 1,
	    subclass_view => "SplicedNASequence",
	    sequence_ontology_id => $splicedNASequenceOntologyId,
	    taxon_id => $taxonId,
	    external_database_release_id => $gusExternalDatabaseRelease->getPrimaryKey(),
	    source_id => $transcript->stable_id(),
	    length => length($seq),
	    sequence => $seq,
	    a_count => $monomersHash->{A},
	    c_count => $monomersHash->{C},
	    t_count => $monomersHash->{T},
	    g_count => $monomersHash->{G},
	    other_count => $otherCount,
    };
}

1;
