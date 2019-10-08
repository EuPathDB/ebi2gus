package EBIParser::AllGenes;
use base qw(EBIParser);

use strict;

# these are required objects
# a gus table definition object will be made for each of them
sub getTables {
    return (['GUS::DoTS::GeneFeature',
	     'GUS::DoTS::ExternalNASequence',
	    ]);
}

sub parse {
    my ($self) = @_;

    my $topLevelSlices = $self->getSlices();
    my $gusTableWriters = $self->getGUSTableWriters();
    
    foreach my $slice (@$topLevelSlices) {
	GUS::DoTS::ExternalNASequence->new($gusTableWriters, $slice)->writeRow();
    
	foreach my $gene ( @{ $slice->get_all_Genes() } ) {
	    GUS::DoTS::GeneFeature->new($gusTableWriters, $gene, $slice)->writeRow();

	}
    }
}

1;


