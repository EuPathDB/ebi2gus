#!/usr/bin/env perl
use strict;
use warnings;

use Bio::EnsEMBL::Registry;

use Data::Dumper;

my $abbrev = "xxxx";
my $outputDir = "/tmp/";
my $fastaFile = $outputDir.$abbrev.".fasta";
my $ecFile = $outputDir.$abbrev."_ecMapping.txt";

my $registry = 'Bio::EnsEMBL::Registry';
my $count = $registry->load_all("/usr/local/etc/ensembl_registry.conf", 1);

outputProteins($registry,$fastaFile,$abbrev);
outputEC($registry,$ecFile,$abbrev);

exit;



sub outputProteins {
    my ($registry,$fastaFile,$abbrev) = @_;
    my $gene_adaptor = $registry->get_adaptor('default','core','gene');
    my $genes = $gene_adaptor->fetch_all_by_biotype('protein_coding');
    my $numberOfGenes = scalar @{$genes};    
    print STDERR "Getting proteins for '$abbrev' from EBI\n";
    print STDERR "Total number of genes: $numberOfGenes\n";

    my $numberOfProteins=0;
    open(FASTA,">",$fastaFile) || die "Cannot open $fastaFile for writing.\n";
    foreach my $gene (@{$genes}) {
	my $geneId = $gene->stable_id();
	my $product = $gene->description();
	$product = "unknown" if (! $product);
	my $transcripts = $gene->get_all_Transcripts();
	foreach my $transcript (@{$transcripts}) {
	    my $transcriptId = $transcript->stable_id();
	    my $translation = $transcript->translation();
	    my $seq = $translation->seq();
	    print FASTA ">$abbrev|$transcriptId gene=$geneId product=$product\n$seq\n";
	    $numberOfProteins++;
	}
    }
    close(FASTA);
    print STDERR "Obtained $numberOfProteins protein sequences.\n";

}




sub outputEC {
    my ($registry,$ecFile,$abbrev) = @_;
    my $gene_adaptor = $registry->get_adaptor('default','core','gene');
    my $genes = $gene_adaptor->fetch_all_by_biotype('protein_coding');
    my $numberOfGenes = scalar @{$genes};
    print STDERR "Getting EC numbers for '$abbrev' from EBI\n";
    print STDERR "Total number of genes: $numberOfGenes\n";

    my $numberOfEcNumbers=0;
    open(EC,">",$ecFile) || die "Cannot open $ecFile for writing.\n";
    foreach my $gene (@{$genes}) {
	my $geneId = $gene->stable_id();
	my %currentGeneEc;
	
	my $xrefs = $gene->get_all_xrefs();
	foreach my $xref (@{$xrefs}) {
	    my $db = $xref->database();
	    if ($db eq "KEGG_Enzyme") {
		my $primary = $xref->primary_id();
		my @ecs = split('\+',$primary);
		foreach my $ec (@ecs) {
		    if ($ec =~ /^[0-9]+\.[0-9\-]+\.[0-9\-]+\.[0-9\-]+$/) {
			$currentGeneEc{$ec}=1;
		    }
		}
	    }
	}

	foreach my $uniqueEc (keys %currentGeneEc) {
	    print EC "$abbrev|$geneId\t$uniqueEc\n";
	    $numberOfEcNumbers++;
	}
	
    }
    close(EC);
    print STDERR "Obtained $numberOfEcNumbers EC numbers.\n";
}

