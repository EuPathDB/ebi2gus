package GUS::DoTS::ExternalNASequence;
use base qw(GUSRow);

use strict;

use Bio::Tools::SeqStats;
use Bio::PrimarySeq;

use Data::Dumper;


sub init {
    my ($self, $slice, $gusTaxon, $gusExternalDatabaseRelease, $gusSequenceOntologyId, $insdc, $organismAbbrev, $registry) = @_;

    my $seqRegionName = $slice->seq_region_name();
    my $secondaryIdentifier;
    my $sequenceSourceId = $seqRegionName;

    my $dbAdaptor = $registry->get_DBAdaptor('default', 'Core');
    my $attribute_adaptor = $dbAdaptor->get_AttributeAdaptor();
    my $attributes = $attribute_adaptor->fetch_all_by_Slice($slice);
    my ($brcSeqRegionAttribute)=  grep { $_->{name} eq 'BRC4_seq_region_name' } @$attributes;

    if($brcSeqRegionAttribute) {
	$sequenceSourceId = $brcSeqRegionAttribute->{value};
	$secondaryIdentifier = $seqRegionName;
    }
    
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
	    secondary_identifier => $secondaryIdentifier,
	    name => $insdc,
	    taxon_id => $gusTaxon->getPrimaryKey(),
	    external_database_release_id => $gusExternalDatabaseRelease->getPrimaryKey(),
	    chromosome => $chromosomeMap->{$sequenceSourceId}->{chromosome},
	    chromosome_order_num => $chromosomeMap->{$sequenceSourceId}->{chromosome_order_num},
	    sequence_ontology_id => $gusSequenceOntologyId
    };
}

1;
