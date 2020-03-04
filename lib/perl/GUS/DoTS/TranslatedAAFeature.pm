package GUS::DoTS::TranslatedAAFeature;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $transcript, $gusTranslatedAASequence, $gusTranscript, $gusExternalDatabaseRelease) = @_;

    my $gusTranslatedAASequenceAsHash  = $gusTranslatedAASequence->getGUSRowAsHash();

    return {aa_sequence_id => $gusTranslatedAASequence->getPrimaryKey(),
	    na_feature_id => $gusTranscript->getPrimaryKey(),
	    subclass_view => "TranslatedAAFeature",
	    source_id => $gusTranslatedAASequenceAsHash->{source_id},
	    translation_start => $transcript->cdna_coding_start(),
	    translation_stop => $transcript->cdna_coding_end(),
	    is_predicted => 0,
	    external_database_release_id => $gusExternalDatabaseRelease->getPrimaryKey(),
    };

}

1;
