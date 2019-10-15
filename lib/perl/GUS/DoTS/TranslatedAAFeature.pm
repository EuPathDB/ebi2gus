package GUS::DoTS::TranslatedAAFeature;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $transcript, $gusTranslatedAASequence, $gusTranscript) = @_;

    my $gusTranslatedAASequenceAsHash  = $gusTranslatedAASequence->getGUSRowAsHash();
    
    my $translation = $transcript->translation();

    return {aa_sequence_id => $gusTranslatedAASequence->getPrimaryKey(),
	    na_feature_id => $gusTranscript->getPrimaryKey(),
	    subclass_view => "TranslatedAAFeature",
	    source_id => $gusTranslatedAASequenceAsHash->{source_id},
	    translation_start => 1,
	    #	    is_predicted => TODO,

   	    # translation_stop => TODO (aaseqlength*3 +3 ?? or cds 
	    
    };

}

1;
