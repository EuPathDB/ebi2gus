package EBIParser::AllGenes;
use base qw(EBIParser);

use strict;

# these are required objects
# a gus table definition object will be made for each of them
sub getTables {
    return (['GUS::DoTS::GeneFeature',
	     'GUS::DoTS::ExternalNASequence',
	     'GUS::DoTS::NALocation',
	     'GUS::DoTS::Transcript',
	     'GUS::DoTS::SplicedNASequence',
	     'GUS::DoTS::ExonFeature',
	     'GUS::DoTS::RNAFeatureExon',
	     
#	     'GUS::ApiDB::Datasource',
#	     'GUS::ApiDB::Organism',
#	     'GUS::SRes::ExternalDatabase',
#	     'GUS::SRes::ExternalDatabaseRelease',

#	     'GUS::DoTS::TranslatedAASequence',
#	     'GUS::DoTS::TranslatedAAFeature',
#	     'GUS::DoTS::AAFeatureExon',
#	     'GUS::DoTS::NAComment',

	    ]);
}

sub parse {
    my ($self) = @_;

    my $topLevelSlices = $self->getSlices();
    my $gusTableWriters = $self->getGUSTableWriters();
    
    foreach my $slice (@$topLevelSlices) {
	my $gusExternalNASequence = GUS::DoTS::ExternalNASequence->new($gusTableWriters, $slice);
    
	foreach my $gene ( @{ $slice->get_all_Genes() } ) {
	    my $gusGeneFeature = GUS::DoTS::GeneFeature->new($gusTableWriters, $gene, $gusExternalNASequence);
	    my $gusGeneNALocation = GUS::DoTS::NALocation->new($gusTableWriters, $gene, $gusGeneFeature);

	    my %exonMap;
	    foreach my $exon ( @{ $gene->get_all_Exons() } ) {
		my $gusExonFeature = GUS::DoTS::ExonFeature->new($gusTableWriters, $exon, $gusGeneFeature);
		my $gusExonNALocation = GUS::DoTS::NALocation->new($gusTableWriters, $exon, $gusExonFeature);
		$exonMap{$exon->dbID()} = $gusExonFeature->getPrimaryKey();
	    }
	    
	    foreach my $transcript ( @{ $gene->get_all_Transcripts() } ) {
		my $gusSplicedNASequence = GUS::DoTS::SplicedNASequence->new($gusTableWriters, $transcript);

		my $gusTranscript = GUS::DoTS::Transcript->new($gusTableWriters, $transcript, $gusGeneFeature, $gusSplicedNASequence);
		my $gusTranscriptNALocation = GUS::DoTS::NALocation::Transcript->new($gusTableWriters, $gusGeneFeature, $gusSplicedNASequence);
		
		my $exonOrderNum = 1;
		foreach my $exon ( @{ $transcript->get_all_ExonTranscripts() } ) {
		    GUS::DoTS::RNAFeatureExon->new($gusTableWriters, $exon, $gusTranscript, \%exonMap, $exonOrderNum);
		    $exonOrderNum++;
		}
	    }
	}
    }
}

1;


