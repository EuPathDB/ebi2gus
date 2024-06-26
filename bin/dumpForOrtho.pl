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
my $uniprotIDFile = $OUTPUT_DIRECTORY.$opt_c;

open(my $logFH,">",$OUTPUT_DIRECTORY.$logFile) || die "Cannot open log file '$logFile' for writing, in directory $OUTPUT_DIRECTORY.\n";
print $logFH "Proteome file: $proteomeFile\n";
print $logFH "UniprotID file: $uniprotIDFile\n";

my $registry = 'Bio::EnsEMBL::Registry';
my $count = $registry->load_all($REGISTRY_CONF_FILE, 1);

outputProteins($registry,$proteomeFile,$abbrev,$logFH);
outputUniprotIDs($registry,$uniprotIDFile,$abbrev,$logFH);

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
	if (! $gene) {
	    print $logFH "Cannot get gene '$gene'\n";
	    die;
	}
	my $geneId = $gene->stable_id();
	if (! $geneId) {
	    print $logFH "Cannot get gene Id '$geneId' of gene '$gene'\n";
	    die;
	}
	my $transcripts = $gene->get_all_Transcripts();
	if (! $transcripts) {
	    print $logFH "Cannot get transcripts '$transcripts' of gene '$geneId'\n";
	    die;
	}
	foreach my $transcript (@{$transcripts}) {
	    if (! $transcript) {
		print $logFH "Cannot get transcript '$transcript' of gene '$gene'\n";
		die;
	    }
	    my $transcriptId = $transcript->stable_id();
	    if (! $transcriptId) {
		print $logFH "Cannot get transcript Id '$transcriptId' of gene '$geneId'\n";
		die;
	    }
            my $product = $transcript->description();
	    $product = "unknown" if (! $product);
	    my $translation = $transcript->translation();
	    if (! $translation) {
		print $logFH "Cannot get translation of transcript '$transcriptId' of gene '$geneId'\n";
		next;
#		die;
	    } else {
	      my $seq = $translation->seq();
	      if (! $seq) {
		print $logFH "Cannot get sequence of translation '$translation' of transcript '$transcriptId' of gene '$gene'\n";
		die;
	      }
	      print FASTA ">$transcriptId gene=$geneId product=$product\n$seq\n";
	      $numberOfProteins++;
	    }
	}
    }
    close(FASTA);
    if ($numberOfProteins==0) {
	print $logFH  "Did not obtain any proteins for orthomcl abbrev '$abbrev'. Exiting.\n" ;
	die;
    }
    print $logFH "Obtained $numberOfProteins protein sequences.\n";

}

sub outputUniprotIDs {
    my ($registry,$uniprotIDFile,$abbrev,$logFH) = @_;
    my $gene_adaptor = $registry->get_adaptor('default','core','gene');
    my $genes = $gene_adaptor->fetch_all_by_biotype('protein_coding');
    my $numberOfGenes = scalar @{$genes};

    print $logFH "Total number of genes: $numberOfGenes\n";

    open(UNI,">",$uniprotIDFile) || die "Cannot open $uniprotIDFile for writing.\n";
    foreach my $gene (@{$genes}) {
	my $geneId = $gene->stable_id();
	my $xrefs = $gene->get_all_xrefs();
	foreach my $xref (@{$xrefs}) {
            my $db = $xref->database();
	    if ($db =~ "^Uniprot") {
		my $primary = $xref->primary_id();
                print UNI "$abbrev|$geneId\t$primary\n";
	    }
	}
    }
    close(UNI);
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
-c     uniprotID_file_name
-b     proteome_file_name

EOM
    exit -1;
}
