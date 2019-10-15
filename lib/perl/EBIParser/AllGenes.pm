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
	     'GUS::DoTS::TranslatedAASequence',	     
	     'GUS::DoTS::TranslatedAAFeature',
	     'GUS::SRes::ExternalDatabase',
	     'GUS::SRes::ExternalDatabaseRelease',
	     'GUS::DoTS::AAFeatureExon',
	     'GUS::SRes::Taxon',
#	     'GUS::DoTS::NAComment',
	    ]);
}

sub getExternalDatabaseRelease {
    my ($self, $gusTableWriters, $organism) = @_;

    my $genomeDatabaseName = $organism->getGenomeDatabaseName();
    my $genomeDatabaseVersion = $organism->getGenomeDatabaseVersion();
    
    my $gusExternalDatabase = GUS::SRes::ExternalDatabase->new($gusTableWriters, $genomeDatabaseName);
    my $gusExternalDatabaseRelease = GUS::SRes::ExternalDatabaseRelease->new($gusTableWriters, $genomeDatabaseVersion, $gusExternalDatabase);

    return $gusExternalDatabaseRelease;
}

sub parse {
    my ($self) = @_;

    my $topLevelSlices = $self->getSlices();
    my $gusTableWriters = $self->getGUSTableWriters();
    my $organism = $self->getOrganism();
    
    my $taxon = GUS::SRes::Taxon->new($gusTableWriters, $organism);
    my $taxonId = $taxon->getPrimaryKey();

    my $gusExternalDatabaseRelease = $self->getExternalDatabaseRelease($gusTableWriters, $organism);
    
    foreach my $slice (@$topLevelSlices) {
	my $gusExternalNASequence = GUS::DoTS::ExternalNASequence->new($gusTableWriters, $slice, $taxon, $gusExternalDatabaseRelease);

	foreach my $gene ( @{ $slice->get_all_Genes() } ) {
	    my $gusGeneFeature = GUS::DoTS::GeneFeature->new($gusTableWriters, $gene, $gusExternalNASequence, $gusExternalDatabaseRelease);
	    my $gusGeneNALocation = GUS::DoTS::NALocation->new($gusTableWriters, $gene, $gusGeneFeature);

	    my %exonMap;
	    foreach my $exon ( @{ $gene->get_all_Exons() } ) {
		my $gusExonFeature = GUS::DoTS::ExonFeature->new($gusTableWriters, $exon, $gusGeneFeature, $gusExternalDatabaseRelease);
		my $gusExonNALocation = GUS::DoTS::NALocation->new($gusTableWriters, $exon, $gusExonFeature);
		$exonMap{$exon->dbID()} = $gusExonFeature->getPrimaryKey();
	    }
	    
	    foreach my $transcript ( @{ $gene->get_all_Transcripts() } ) {
		my $gusSplicedNASequence = GUS::DoTS::SplicedNASequence->new($gusTableWriters, $transcript, $taxonId, $gusExternalDatabaseRelease);

		my $gusTranscript = GUS::DoTS::Transcript->new($gusTableWriters, $transcript, $gusGeneFeature, $gusSplicedNASequence, $gusExternalDatabaseRelease);
		my $gusTranscriptNALocation = GUS::DoTS::NALocation::Transcript->new($gusTableWriters, $gusGeneFeature, $gusSplicedNASequence);

		#TODO:  
		#if(CODING) {
		my $gusTranslatedAASequence = GUS::DoTS::TranslatedAASequence->new($gusTableWriters, $transcript, $taxonId, $gusExternalDatabaseRelease);
		my $gusTranslatedAAFeature = GUS::DoTS::TranslatedAAFeature->new($gusTableWriters, $transcript, $gusTranslatedAASequence, $gusTranscript, $gusExternalDatabaseRelease);
		#}

		
		my $exonOrderNum = 1;
		foreach my $exon ( @{ $transcript->get_all_ExonTranscripts() } ) {
		    GUS::DoTS::RNAFeatureExon->new($gusTableWriters, $exon, $gusTranscript, \%exonMap, $exonOrderNum);

#		    GUS::DoTS::AAFeatureExon->new($gusTableWriters, $exon, $gusTranslatedAAFeature, \%exonMap);
		    
		    $exonOrderNum++;
		}

		
	    }

	    exit;
	}
    }
}

1;


