package GUS::DoTS::Transcript;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $transcript, $gusGeneFeature, $gusSplicedNASequence, $gusExternalDatabaseRelease) = @_;

    my $naSequenceId = $gusSplicedNASequence->getPrimaryKey();

    return {};
}

1;
