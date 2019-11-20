#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Std;

use Bio::EnsEMBL::Registry;

use GUSTableDefinitionParser;
use Organism;

use EBIParser;

use Data::Dumper;

my $REGISTRY_CONF_FILE = "/usr/local/etc/ensembl_registry.conf";
my $TABLE_DEFINITIONS_XML_FILE = "/usr/local/etc/gusSchemaDefinitions.xml";


my $OUTPUT_DIRECTORY = "/tmp";

sub HELP_MESSAGE {
    print STDERR <<"EOM";
usage : $0 -r ensemble_registry_file \\
        -t table_definitions_xml_file \\
	-d genome_database_name \\
	-v genome_database_version \\
	-n ncbi_tax_id \\
	-a organism_abbrev \\
	-c chromosome_map_file \\
        -o output_directory
EOM
    exit -1;
}
our ($opt_r, $opt_a, $opt_o, $opt_t, $opt_h, $opt_v, $opt_n, $opt_c, $opt_d);
getopts('r:o:t:v:n:c:h:d:a:') or HELP_MESSAGE();

HELP_MESSAGE() if($opt_h);
$REGISTRY_CONF_FILE = $opt_r if($opt_r);
$TABLE_DEFINITIONS_XML_FILE = $opt_t if($opt_t);
$OUTPUT_DIRECTORY = $opt_o if($opt_o);

my $ncbiTaxId = $opt_n;
my $organismAbbrev = $opt_a;
my $genomeDatabaseName = $opt_d;
my $genomeDatabaseVersion = $opt_v;
my $chromosomeMapFile = $opt_c;

if($opt_h || 
   !-e $REGISTRY_CONF_FILE || !-e $TABLE_DEFINITIONS_XML_FILE || 
   !defined($ncbiTaxId) || !$genomeDatabaseVersion || 
   !$genomeDatabaseName || !$organismAbbrev) { 
    HELP_MESSAGE();
}

if($chromosomeMapFile && !-e $chromosomeMapFile) {
    HELP_MESSAGE();
}

my $gusTableDefinitions = GUSTableDefinitionParser->new($TABLE_DEFINITIONS_XML_FILE);

my $organism = Organism->new($ncbiTaxId, $organismAbbrev, $genomeDatabaseName, $genomeDatabaseVersion, $chromosomeMapFile);

my $registry = 'Bio::EnsEMBL::Registry';

my $count = $registry->load_all($REGISTRY_CONF_FILE, 1);

my $sliceAdaptor = $registry->get_adaptor('default', 'Core', 'Slice' );

my $topLevelSlices = $sliceAdaptor->fetch_all('toplevel');

my $ebiParser = EBIParser->new($topLevelSlices, $gusTableDefinitions, $OUTPUT_DIRECTORY, $organism, $registry);
$ebiParser->parse();
# exit;


# my $goa = $registry->get_adaptor( 'default', 'Core', 'OntologyTerm' );
# print Dumper $goa;
# exit;


# my $analysisAdaptor = $registry->get_adaptor('default', 'Core', 'Analysis' );
# my $analysis = $analysisAdaptor->fetch_by_logic_name("interpro2go");
# print Dumper $analysis;      
# exit;


# my $analysis = $analysisAdaptor->fetch_by_logic_name('superfamily');

# print Dumper $analysis;


#TODO  sres.ontology ??
  # keep a running list of seen so_terms.  Dump them out at the end to "SRes.OntologyTerm" file




1;



