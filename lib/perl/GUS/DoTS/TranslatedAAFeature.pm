package GUS::DoTS::TranslatedAAFeature;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $transcript, $gusTranslatedAASequence, $gusTranscript, $gusExternalDatabaseRelease) = @_;

    my $gusTranslatedAASequenceAsHash  = $gusTranslatedAASequence->getGUSRowAsHash();
    
    my $translation = $transcript->translation();

    my $translationStop = $translation->cdna_end() - $translation->cdna_start() + 1;

    return {aa_sequence_id => $gusTranslatedAASequence->getPrimaryKey(),
	    na_feature_id => $gusTranscript->getPrimaryKey(),
	    subclass_view => "TranslatedAAFeature",
	    source_id => $gusTranslatedAASequenceAsHash->{source_id},
	    translation_start => 1,
	    translation_stop => $translationStop,
	    is_predicted => 0,
	    external_database_release_id => $gusExternalDatabaseRelease->getPrimaryKey(),
    };

}

1;
