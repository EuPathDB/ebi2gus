#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Std;

use Bio::EnsEMBL::Registry;

use GUSTableDefinitionParser;

use EBIParser::AllGenes;

my $REGISTRY_CONF_FILE = "/usr/local/etc/ensembl_registry.conf";
#my $ONOTLOGY_FILE = "/usr/local/etc/ontologyMappings.xml"; #TODO
my $TABLE_DEFINITIONS_XML_FILE = "/usr/local/etc/gusSchemaDefinitions.xml";

#TODO
my $OUTPUT_DIRECTORY = "$ENV{HOME}/tmp";


sub HELP_MESSAGE {
    print STDERR <<"EOM";
usage : $0 [-r ensemble_regisrty_file] [-o ontology_file] [-t table_definitions_xml_file] 
        -r ensemble_registry_file
        -o ontology_file
        -t table_definitions_xml_file
EOM
    exit 0;
}
our ($opt_r, $opt_o, $opt_t, $opt_h);
getopts('r:o:t:') or HELP_MESSAGE();

HELP_MESSAGE() if($opt_h);
$REGISTRY_CONF_FILE = $opt_r if($opt_r);
$TABLE_DEFINITIONS_XML_FILE = $opt_t if($opt_t);
#$ONTOLOGY_FILE = $opt_0 if($opt_o);

if($opt_h || !-e $REGISTRY_CONF_FILE || !-e $TABLE_DEFINITIONS_XML_FILE) {
#if($opt_h || !-e $REGISTRY_CONF_FILE || !-e $TABLE_DEFINITIONS_XML_FILE || !-e $ONTOLOGY_FILE) { # TODO add back ontology file
    HELP_MESSAGE();
}

my $gusTableDefinitions = GUSTableDefinitionParser->new($TABLE_DEFINITIONS_XML_FILE);

my $registry = 'Bio::EnsEMBL::Registry';

my $count = $registry->load_all($REGISTRY_CONF_FILE, 1);

my $sliceAdaptor = $registry->get_adaptor('default', 'Core', 'Slice' );

my $topLevelSlices = $sliceAdaptor->fetch_all('toplevel');


#TODO sres.ontology ??
#TODO sres.externaldatabase, sres.externaldatbaserelease, apidb.datasource ?? 
#other global stuff?

# TODO: write a row for SRes.Taxon for this strain.  Take ncbi_tax_id from organism configuration


my $geneDumper = EBIParser::AllGenes->new($topLevelSlices, $gusTableDefinitions, $OUTPUT_DIRECTORY);
$geneDumper->parse();




1;



