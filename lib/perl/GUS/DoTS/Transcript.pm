package GUS::DoTS::Transcript;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $transcript, $gusGeneFeature, $gusSplicedNASequence) = @_;

    my $naSequenceId = $gusSplicedNASequence->getPrimaryKey();
}

1;
