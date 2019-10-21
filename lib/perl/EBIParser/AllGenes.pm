package EBIParser::AllGenes;
use base qw(EBIParser);

use strict;

use Data::Dumper;

use GUS::SRes::OntologyTerm qw(%seenOntologyTerms);

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
	     'GUS::SRes::OntologyTerm',
	     'GUS::ApiDB::AaSequenceAttribute',
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


sub ontologyTermForSlice {
    my ($self, $slice, $gusTableWriters) = @_;

    # TODO:  get coord map type (chromosome, scaffold, chunk)
    my $name = 'chromosome';

    return $self->ontologyTermFromName($name, $gusTableWriters);
}

sub ontologyTermFromBiotype {
    my ($self, $biotype, $gusTableWriters) = @_;

    my $name = $biotype->name();
    
    if($seenOntologyTerms{$name}) {
	return $seenOntologyTerms{$name};
    }

    return GUS::SRes::OntologyTerm->new($gusTableWriters, $biotype)->getPrimaryKey();
}

sub ontologyTermFromName {
    my ($self, $name, $gusTableWriters) = @_;

    if($seenOntologyTerms{$name}) {
	return $seenOntologyTerms{$name};
    }

    return GUS::SRes::OntologyTerm->new($gusTableWriters, $name)->getPrimaryKey();
}


sub parseSlice {
    my ($self, $slice, $gusExternalDatabaseRelease, $gusTaxon) = @_;

    my $gusTableWriters = $self->getGUSTableWriters();

    my $gusSequenceOntologyId = $self->ontologyTermForSlice($slice, $gusTableWriters);
    my $gusExternalNASequence = GUS::DoTS::ExternalNASequence->new($gusTableWriters, $slice, $gusTaxon, $gusExternalDatabaseRelease, $gusSequenceOntologyId);
    
    foreach my $gene (@{$slice->get_all_Genes()}) {
	$self->parseGene($gene, $gusExternalDatabaseRelease, $gusTaxon, $gusExternalNASequence);
    }


    exit;
    
    # Repeats, Trnascan,. ...
#    foreach my $alignFeature (@{$slice->get_all_DnaAlignFeatures()} ) {

#    }


    
    
}

sub parseGene {
    my ($self, $gene, $gusExternalDatabaseRelease, $gusTaxon, $gusExternalNASequence) = @_;

    my $gusTableWriters = $self->getGUSTableWriters();
    

    my $geneSequenceOntologyId = $self->ontologyTermFromBiotype($gene->get_Biotype(), $gusTableWriters);
    my $gusGeneFeature = GUS::DoTS::GeneFeature->new($gusTableWriters, $gene, $gusExternalNASequence, $gusExternalDatabaseRelease, $geneSequenceOntologyId);
    my $gusGeneNALocation = GUS::DoTS::NALocation->new($gusTableWriters, $gene, $gusGeneFeature);

    my $taxonId = $gusTaxon->getPrimaryKey();
    
    my %exonMap;
    my $exonSequenceOntologyId = $self->ontologyTermFromName("exon", $gusTableWriters);
    foreach my $exon ( @{ $gene->get_all_Exons() } ) {
	my $gusExonFeature = GUS::DoTS::ExonFeature->new($gusTableWriters, $exon, $gusGeneFeature, $gusExternalDatabaseRelease, $exonSequenceOntologyId);
	my $gusExonNALocation = GUS::DoTS::NALocation->new($gusTableWriters, $exon, $gusExonFeature);
	$exonMap{$exon->dbID()} = $gusExonFeature->getPrimaryKey();
    }
    
    foreach my $transcript ( @{ $gene->get_all_Transcripts() } ) {
	my $splicedNASequenceOntologyId = $self->ontologyTermFromName("mature_transcript", $gusTableWriters);
	my $gusSplicedNASequence = GUS::DoTS::SplicedNASequence->new($gusTableWriters, $transcript, $taxonId, $gusExternalDatabaseRelease, $splicedNASequenceOntologyId);
	
	my $transcriptSequenceOntologyId = $self->ontologyTermFromBiotype($transcript->get_Biotype(), $gusTableWriters);
	my $gusTranscript = GUS::DoTS::Transcript->new($gusTableWriters, $transcript, $gusGeneFeature, $gusSplicedNASequence, $gusExternalDatabaseRelease, $transcriptSequenceOntologyId);
	my $gusTranscriptNALocation = GUS::DoTS::NALocation::Transcript->new($gusTableWriters, $gusGeneFeature, $gusSplicedNASequence);

	if($gene->get_Biotype()->name() eq "protein_coding") {

	    my $translation = $transcript->translation();

	    

	    
	    # my $pfeatures = $translation->get_all_ProteinFeatures("");
	    # while ( my $pfeature = shift @{$pfeatures} ) {
	    # 	print $pfeature->p_value();
	    # 	print "\n\n";
	    # 	print Dumper $pfeature;
	    # 	exit;
	    # }

	    my $translatedAASequenceOntologyId = $self->ontologyTermFromName("polypeptide", $gusTableWriters);
	    my $gusTranslatedAASequence = GUS::DoTS::TranslatedAASequence->new($gusTableWriters, $transcript, $taxonId, $gusExternalDatabaseRelease, $translatedAASequenceOntologyId);

	    GUS::ApiDB::AaSequenceAttribute->new($gusTableWriters, $translation, $gusTranslatedAASequence);

	    
	    my $gusTranslatedAAFeature = GUS::DoTS::TranslatedAAFeature->new($gusTableWriters, $transcript, $gusTranslatedAASequence, $gusTranscript, $gusExternalDatabaseRelease);

	    my $exonOrderNum = 1;
	    foreach my $exonTranscript ( @{ $transcript->get_all_ExonTranscripts() } ) {
		my $exon = $exonTranscript->exon();

		my $gusExonId = $exonMap{$exon->dbID()};
		GUS::DoTS::RNAFeatureExon->new($gusTableWriters, $gusExonId, $gusTranscript, $exonOrderNum);

		my $codingRegionStart = $exon->coding_region_start($transcript);
		my $codingRegionEnd = $exon->coding_region_end($transcript);
		if(defined $codingRegionStart) {
		    GUS::DoTS::AAFeatureExon->new($gusTableWriters, $gusTranslatedAAFeature, $gusExonId, $codingRegionStart, $codingRegionEnd);		    
		}

		$exonOrderNum++;
	    }
	}
	else {
	    my $exonOrderNum = 1;
	    foreach my $exonTranscript ( @{ $transcript->get_all_ExonTranscripts() } ) {
		my $exon = $exonTranscript->exon();
		my $gusExonId = $exonMap{$exon->dbID()};
		GUS::DoTS::RNAFeatureExon->new($gusTableWriters, $gusExonId, $gusTranscript, $exonOrderNum);
		$exonOrderNum++;
	    }
	}
	
    }
}



sub parse {
    my ($self) = @_;

    my $topLevelSlices = $self->getSlices();
    my $gusTableWriters = $self->getGUSTableWriters();
    my $organism = $self->getOrganism();
    
    my $gusTaxon = GUS::SRes::Taxon->new($gusTableWriters, $organism);

    my $gusExternalDatabaseRelease = $self->getExternalDatabaseRelease($gusTableWriters, $organism);
    
    foreach my $slice (@$topLevelSlices) {
	$self->parseSlice($slice, $gusExternalDatabaseRelease, $gusTaxon);
    }
}

1;


