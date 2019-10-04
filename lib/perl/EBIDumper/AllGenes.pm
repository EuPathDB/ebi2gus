package EBIDumper::AllGenes;
use base qw(EBIDumper);

use strict;

sub convert {
    my ($self) = @_;

    my $topLevelSequences = $self->getSequences();
    
    foreach my $seq (@$topLevelSequences) {
    
	foreach my $gene ( @{ $seq->get_all_Genes() } ) {

	    my $dbid       = $gene->dbID();
	    my $id         = $gene->stable_id();
	    
	    my $start      = $gene->start();
	    my $end        = $gene->end();
	    my $strand     = $gene->strand();
	    print join("\t", $dbid, $id, $start, $end, $strand, "\n");
	}
    }
}

1;


