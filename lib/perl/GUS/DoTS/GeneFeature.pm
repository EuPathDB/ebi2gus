package GUS::DoTS::GeneFeature;
use base qw(GUSRow);

use strict;

use Data::Dumper;

sub init {
    my ($self, $ebiGene, $sequence) = @_;

    print STDERR "GeneFeature init\n";

    print Dumper $ebiGene;
    
    exit;
    return {}
}

1;
