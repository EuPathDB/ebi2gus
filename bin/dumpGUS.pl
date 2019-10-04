#!/usr/bin/env perl

use strict;
use warnings;

use Bio::EnsEMBL::Registry;

use EBIDumper::AllGenes;

print "dumpGUS starting\n";

my $REGISTRY_CONF_FILE = "/usr/local/etc/ensembl_registry.conf";

my $registry = 'Bio::EnsEMBL::Registry';

my $count = $registry->load_all($REGISTRY_CONF_FILE, 1);

my $sliceAdaptor = $registry->get_adaptor('default', 'Core', 'Slice' );

my $topLevelSequences = $sliceAdaptor->fetch_all('toplevel');




my $geneDumper = EBIDumper::AllGenes->new($topLevelSequences);
$geneDumper->convert();

1;



