#!/usr/bin/env perl
use strict;
use warnings;

use Bio::EnsEMBL::Registry;

use Data::Dumper;

my $registry = 'Bio::EnsEMBL::Registry';

my $count = $registry->load_all("/usr/local/etc/ensembl_registry.conf", 1);

my $slice_adaptor = $registry->get_adaptor('default', 'Core', 'Slice' );

my @chromosomes = @{ $slice_adaptor->fetch_all('chromosome') };




my ($totalGenes, $totalTranscripts, $totalProteinCodingGenes, $totalProteinCodingTranscripts);
foreach my $chr (@chromosomes) {

    $totalGenes += @{ $chr->get_all_Genes() };
    $totalProteinCodingGenes += @{ $chr->get_all_Genes_by_type('protein_coding') };

    $totalTranscripts += @{ $chr->get_all_Transcripts() };
    $totalProteinCodingTranscripts += @{ $chr->get_all_Transcripts_by_type('protein_coding') };

    
         foreach my $gene ( @{ $chr->get_all_Transcripts() } ) {

#	     print Dumper $gene;
#	     exit;
	     my $dbid       = $gene->dbID();
	     my $id         = $gene->stable_id();

	     my $start      = $gene->start();
	     my $end        = $gene->end();
	     my $strand     = $gene->strand();
	     print join("\t", $dbid, $id, $start, $end, $strand, "\n");
	 }
}


print "Total Genes=$totalGenes\n";
print "Total Protein Coding Genes=$totalProteinCodingGenes\n";
print "Total Transcripts=$totalTranscripts\n";
print "Total Protein Coding Transcripts=$totalProteinCodingTranscripts\n";


1;
