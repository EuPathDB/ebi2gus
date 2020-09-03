#!/usr/bin/env perl
use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Getopt::Std;
use Data::Dumper;

my $REGISTRY_CONF_FILE = "/usr/local/etc/ensembl_registry.conf";
my $OUTPUT_DIRECTORY = "/tmp/";
my $logFile = "log.txt";

our ($opt_a, $opt_b, $opt_c, $opt_o, $opt_h, $opt_e);
getopts('ho:e:a:b:c:') or HELP_MESSAGE();
$OUTPUT_DIRECTORY = $opt_o if($opt_o);
$REGISTRY_CONF_FILE = $opt_e if($opt_e);
my $abbrev = $opt_a;
HELP_MESSAGE() if($opt_h || !-e $REGISTRY_CONF_FILE || !-e $OUTPUT_DIRECTORY || ! $abbrev || ! $opt_b || ! $opt_c);

my $proteomeFile = $OUTPUT_DIRECTORY.$opt_b;
my $ecFile = $OUTPUT_DIRECTORY.$opt_c;
open($logFH,">",$OUTPUT_DIRECTORY.$logFile) || die "Cannot open log file '$logFile' for writing, in directory $OUTPUT_DIRECTORY.\n";

my $registry = 'Bio::EnsEMBL::Registry';
my $count = $registry->load_all($REGISTRY_CONF_FILE, 1);

outputProteins($registry,$proteomeFile,$abbrev,$logFH);
outputEC($registry,$ecFile,$abbrev,$logFH);

close ($logFH);

exit;



sub outputProteins {
    my ($registry,$fastaFile,$abbrev,$logFH) = @_;
    my $gene_adaptor = $registry->get_adaptor('default','core','gene');
    my $genes = $gene_adaptor->fetch_all_by_biotype('protein_coding');
    my $numberOfGenes = scalar @{$genes};    
    print $logFH "Getting proteins for '$abbrev' from EBI\n";
    print $logFH "Total number of genes: $numberOfGenes\n";

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
    print $logFH "Obtained $numberOfProteins protein sequences.\n";

}

sub outputEC {
    my ($registry,$ecFile,$abbrev,$logFH) = @_;
    my $gene_adaptor = $registry->get_adaptor('default','core','gene');
    my $genes = $gene_adaptor->fetch_all_by_biotype('protein_coding');
    my $numberOfGenes = scalar @{$genes};
    print $logFH "Getting EC numbers for '$abbrev' from EBI\n";
    print $logFH "Total number of genes: $numberOfGenes\n";

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
    print $logFH "Obtained $numberOfEcNumbers EC numbers.\n";
}

sub HELP_MESSAGE {
    print STDERR <<"EOM";

USAGE:
$0 [-h] -e FILE -a STRING -o DIRECTORY -b STRING -c STRING

OPTIONS:

-h     print this message
-e     ensemble_registry_file
-a     orthomcl abbrev
-o     output_directory
-c     ec_file_name
-b     proteome_file_name

EOM
    exit -1;
}
