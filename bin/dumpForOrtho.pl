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
my $interproFile = $OUTPUT_DIRECTORY."interproResults.tsv";

open(my $logFH,">",$OUTPUT_DIRECTORY.$logFile) || die "Cannot open log file '$logFile' for writing, in directory $OUTPUT_DIRECTORY.\n";
print $logFH "Proteome file: $proteomeFile\n";
print $logFH "EC file: $ecFile\n";

open(my $iprFH,">>",$interproFile) || die "Cannot open interpro file $interproFile\n";

my $registry = 'Bio::EnsEMBL::Registry';
my $count = $registry->load_all($REGISTRY_CONF_FILE, 1);

outputProteins($registry,$proteomeFile,$abbrev,$logFH, $iprFH);
outputEC($registry,$ecFile,$abbrev,$logFH);

close ($interproFile);
close ($logFH);

exit;

sub parseProteinFeature {
    my ($proteinFeature, $translation, $geneId, $transcriptId, $abbrev, $iprFH) = @_;

    my $proteinId = $proteinFeature->display_id();

    &parseInterpro($proteinFeature, $geneId, $proteinId, $transcriptId, $abbrev, $iprFH);
    
}

sub parseInterpro {
    my ($interproFeature, $geneId, $proteinId, $transcriptId, $abbrev, $iprFH) = @_;
    my $interproPrimaryId = $interproFeature->interpro_ac();
    my $interproSecondaryId = $interproFeature->ilabel();
    my $interproName = $analysis->program();
    my $interproVersion = $analysis->program_version();
    my $interproStart = $interproFeature->start();
    my $interproEnd = $interproFeature->end();
    my $evalue = $interproFeature->p_value(); # documentation says e value is gotten from p_value method
    my $remark = $interproFeature->idesc(); #this is the interpro description used as the dbref remark for both
    my $domainPrimaryId = $interproFeature->display_id();    
    my $domainSecondaryId = $interproFeature->hdescription();
    my $analysis = $interproFeature->analysis();
    my $name = $analysis->display_label() ? $analysis->display_label() : $analysis->logic_name();
    my $version = $analysis->db_version();
    print $iprFH "$transcriptId\t$proteinId\t$geneId\tOrthoMCL\t$abbrev\t$name\t$interproPrimaryId\t$interproSecondaryId\t$interproName\t$interproVersion\t$interproStart\t$interproEnd\t$domainPrimaryId\t$domainSecondaryId\t$version\t$analysis\t$remark\t$evalue\n";
}

sub outputProteins {
    my ($registry,$fastaFile,$abbrev,$logFH,$iprFH) = @_;
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
	my $product = $gene->description();
	$product = "unknown" if (! $product);
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
	    my $translation = $transcript->translation();
	    if (! $translation) {
		print $logFH "Cannot get translation of transcript '$transcriptId' of gene '$geneId'\n";
		next;
#		die;
	    } else {
	      foreach my $proteinFeature (@{$translation->get_all_ProteinFeatures()}) {
                  &parseProteinFeature($proteinFeature, $translation, $geneId, $transcriptId, $abbrev, $iprFH);
              }
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
