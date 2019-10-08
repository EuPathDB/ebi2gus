package EBIDumper::AllGenes;
use base qw(EBIDumper);

use strict;

# these are required objects
# a gus table definition object will be made for each of them
sub getTables {
    return (['GUS::DoTS::GeneFeature']);
}

sub convert {
    my ($self) = @_;

    my $topLevelSequences = $self->getSequences();
    my $gusTableWriters = $self->getGUSTableWriters();
    
    foreach my $seq (@$topLevelSequences) {
    
	foreach my $gene ( @{ $seq->get_all_Genes() } ) {
	    GUS::DoTS::GeneFeature->new($gusTableWriters, $gene, $seq)->writeRow();


	    
	    # my $dbid       = $gene->dbID();
	    # my $id         = $gene->stable_id();
	    
	    # my $start      = $gene->start();
	    # my $end        = $gene->end();
	    # my $strand     = $gene->strand();
	    # print join("\t", $dbid, $id, $start, $end, $strand, "\n");
	}
    }
}

1;


