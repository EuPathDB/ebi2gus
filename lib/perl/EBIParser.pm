package EBIParser;

use strict;

use Data::Dumper;

use GUSTableWriter;
use OutputFile;

use GUS::SRes::OntologyTerm qw(%seenOntologyTerms);
use GUS::SRes::ExternalDatabase qw(%seenExternalDatabases);
use GUS::SRes::ExternalDatabaseRelease qw(%seenExternalDatabaseReleases);
use GUS::SRes::DbRef qw(%seenDBRefs);


my %INTERPRO_LOGICS = ('pfam' => 1,
		       'pirsf' => 1,
		       'cdd' => 1,
		       'hamap' => 1,
		       'hmmpanther' => 1,
		       'prints' => 1,
		       'scanprosite' => 1,
		       'sfld' => 1,
		       'smart' => 1,
		       'superfamily' => 1,
		       'tigrfam' => 1,
    );

my %SKIP_LOGICS = ('mobidblite' => 1,
		   'pfscan' => 1,
		   'ncoils' => 1,
		   'blastprodom' => 1,
		   'gene3d' => 1,
    );


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
	     'GUS::DoTS::LowComplexityNAFeature',
	     'GUS::DoTS::TransposableElement',
	     'GUS::DoTS::TandemRepeatFeature',
	     'GUS::DoTS::Repeats',
	     'GUS::DoTS::SignalPeptideFeature',
	     'GUS::DoTS::TransMembraneAAFeature',
	     'GUS::DoTS::LowComplexityAAFeature',
	     'GUS::DoTS::AALocation',
	     'GUS::SRes::DbRef',
	     'GUS::DoTS::DbRefAAFeature',
	     'GUS::DoTS::DomainFeature',
#	     'GUS::DoTS::NAComment',
	    ]);
}



sub getSlices { $_[0]->{_slices} }
sub setSlices { $_[0]->{_slices} = $_[1] }

sub getRegistry { $_[0]->{_registry} }
sub setRegistry { $_[0]->{_registry} = $_[1] }

sub getOrganism { $_[0]->{_organism} }
sub setOrganism { $_[0]->{_organism} = $_[1] }

sub getGUSTableWriters { $_[0]->{_gus_table_writers} }
sub setGUSTableWriters { 
    my ($self, $gusTableDefinitionsParser, $outputDirectory) = @_;

    my $tables = $self->getTables();

    my $gusTableWriters = {};

    my %outputFiles;
    
    foreach my $className (@$tables) {
	$className =~ s/^GUS:://;
	$className =~ s/::/./;

	$className = uc $className;
	
	my $gusTableDefinition = $gusTableDefinitionsParser->makeTableDefinition($className);
	my $realTableName = $gusTableDefinition->getRealTableName();

	my $outputFile; #Only one fileName/FileHandle/Counter Per RealTableName
	if($outputFiles{$realTableName}) {
	    $outputFile = $outputFiles{$realTableName};
	}
	else {
	    my $headerFields = $gusTableDefinition->getFields();

	    $outputFile = OutputFile->new($realTableName, $outputDirectory, $headerFields);
	    $outputFiles{$realTableName} = $outputFile;
	}
	
	$gusTableWriters->{$className} = GUSTableWriter->new($gusTableDefinition, $outputFile);
    }

    $self->{_gus_table_writers} = $gusTableWriters;
}

sub getTables { $_[0]->{_tables} || [] }
sub setTables { $_[0]->{_tables} = $_[1] }

sub new {
    my ($class, $slices, $gusTableDefinitions, $outputDirectory, $organism, $registry) = @_;

    my $self = bless {}, $class;

    $self->setSlices($slices);
    $self->setGUSTableWriters($gusTableDefinitions, $outputDirectory);
    $self->setOrganism($organism);

    $self->setRegistry($registry);
    
    $self->importTableModules();
    
    return $self;
}

sub importTableModules {
    my ($self) = @_;

    my $tables = $self->getTables();

    foreach(@$tables) {
	eval "require $_";
	if($@) {
	    die $@;
	}
    }
}


sub getExternalDatabaseRelease {
    my ($self, $gusTableWriters, $organism) = @_;

    my $genomeDatabaseName = $organism->getGenomeDatabaseName();
    my $genomeDatabaseVersion = $organism->getGenomeDatabaseVersion();
    
    my $gusExternalDatabase = GUS::SRes::ExternalDatabase->new($gusTableWriters, $genomeDatabaseName);
    my $gusExternalDatabaseRelease = GUS::SRes::ExternalDatabaseRelease->new($gusTableWriters, $genomeDatabaseVersion, $gusExternalDatabase->getPrimaryKey());

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

    # TODO:  genomic sequence synonyms / dbXRefs
    foreach my $sliceSynonym (@{$slice->get_all_synonyms()}) {
	print "NAME=" . $sliceSynonym->name() . "\n";
    }


    foreach my $gene (@{$slice->get_all_Genes()}) {
	$self->parseGene($gene, $gusExternalDatabaseRelease, $gusTaxon, $gusExternalNASequence);

    }

    foreach my $repeatFeature (@{$slice->get_all_RepeatFeatures()} ) {
	$self->parseRepeatFeature($repeatFeature, $gusExternalDatabaseRelease, $gusExternalNASequence);
    }

}

sub parseRepeatFeature {
    my ($self, $repeatFeature, $gusExternalDatabaseRelease, $gusExternalNASequence) = @_;

    my $gusTableWriters = $self->getGUSTableWriters();
    my $logicName = $repeatFeature->analysis()->logic_name();

    my $gusFeature;
    
    if($logicName eq "dust") {
	$gusFeature = GUS::DoTS::LowComplexityNAFeature->new($gusTableWriters, $repeatFeature, $gusExternalNASequence, $gusExternalDatabaseRelease);
    }
    elsif($logicName eq "tefam") {
	$gusFeature = GUS::DoTS::TransposableElement->new($gusTableWriters, $repeatFeature, $gusExternalNASequence, $gusExternalDatabaseRelease);
    }
    elsif($logicName eq "trf") {
	$gusFeature = GUS::DoTS::TandemRepeatFeature->new($gusTableWriters, $repeatFeature, $gusExternalNASequence, $gusExternalDatabaseRelease);	
    }
    elsif($logicName =~ /^repeatmask_/) {
	$gusFeature = GUS::DoTS::Repeats->new($gusTableWriters, $repeatFeature, $gusExternalNASequence, $gusExternalDatabaseRelease);		
    }
    else {
	die "unknown repeat feature type:  $logicName";
    }

    GUS::DoTS::NALocation->new($gusTableWriters, $repeatFeature, $gusFeature);
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
	$self->parseTranscript($transcript, $gene, $gusGeneFeature, $taxonId, \%exonMap, $gusExternalDatabaseRelease);
    }


    # DBRef 
    foreach(@{$gene->get_all_object_xrefs()}) {
#	print Dumper $_;
#	exit;
	print  "GENE\t" . $_->db_display_name () . "\t";
	print  $_->primary_id () . "\n";
    }
}



sub parseTranscript {
    my ($self, $transcript, $gene, $gusGeneFeature, $taxonId, $exonMap, $gusExternalDatabaseRelease) = @_;

    my $gusTableWriters = $self->getGUSTableWriters();

    my $splicedNASequenceOntologyId = $self->ontologyTermFromName("mature_transcript", $gusTableWriters);
    my $gusSplicedNASequence = GUS::DoTS::SplicedNASequence->new($gusTableWriters, $transcript, $taxonId, $gusExternalDatabaseRelease, $splicedNASequenceOntologyId);
    
    my $transcriptSequenceOntologyId = $self->ontologyTermFromBiotype($transcript->get_Biotype(), $gusTableWriters);
    my $gusTranscript = GUS::DoTS::Transcript->new($gusTableWriters, $transcript, $gusGeneFeature, $gusSplicedNASequence, $gusExternalDatabaseRelease, $transcriptSequenceOntologyId);
    my $gusTranscriptNALocation = GUS::DoTS::NALocation::Transcript->new($gusTableWriters, $gusGeneFeature, $gusSplicedNASequence);

    my $geneType = $gene->get_Biotype()->name();

    my $gusTranslatedAAFeature;
    if($geneType eq "protein_coding") {
	my $translation = $transcript->translation();

	print "NEW TRANSLATION\n";
	$gusTranslatedAAFeature = $self->parseTranslation($translation, $transcript, $gusTranscript, $taxonId, $gusExternalDatabaseRelease);
    }

    my $exonOrderNum = 1;
    foreach my $exonTranscript ( @{ $transcript->get_all_ExonTranscripts() } ) {
	my $exon = $exonTranscript->exon();

	my $gusExonId = $exonMap->{$exon->dbID()};
	GUS::DoTS::RNAFeatureExon->new($gusTableWriters, $gusExonId, $gusTranscript, $exonOrderNum);

	if($geneType eq "protein_coding") {
	    my $codingRegionStart = $exon->coding_region_start($transcript);
	    my $codingRegionEnd = $exon->coding_region_end($transcript);
	    if(defined $codingRegionStart) {
		GUS::DoTS::AAFeatureExon->new($gusTableWriters, $gusTranslatedAAFeature, $gusExonId, $codingRegionStart, $codingRegionEnd);		    
	    }
	}
	$exonOrderNum++;
    }

    # DBRef 
    foreach(@{$transcript->get_all_object_xrefs()}) {
#	print Dumper $_;
#	exit;
	print  "TRANSCRIPT\t" . $_->db_display_name () . "\t";
	print  $_->primary_id () . "\n";
    }

    
}

sub parseTranslation {
    my ($self, $translation, $transcript, $gusTranscript, $taxonId, $gusExternalDatabaseRelease) = @_;

    # DBRef 
    foreach(@{$translation->get_all_object_xrefs()}) {
	print  "TRANSLATION\t" . $_->db_display_name () . "\t";
	print  $_->primary_id () . "\n";
    }
    
    my $gusTableWriters = $self->getGUSTableWriters();
    
    my $translatedAASequenceOntologyId = $self->ontologyTermFromName("polypeptide", $gusTableWriters);
    my $gusTranslatedAASequence = GUS::DoTS::TranslatedAASequence->new($gusTableWriters, $transcript, $taxonId, $gusExternalDatabaseRelease, $translatedAASequenceOntologyId);

    GUS::ApiDB::AaSequenceAttribute->new($gusTableWriters, $translation, $gusTranslatedAASequence);

    my $gusTranslatedAAFeature = GUS::DoTS::TranslatedAAFeature->new($gusTableWriters, $transcript, $gusTranslatedAASequence, $gusTranscript, $gusExternalDatabaseRelease);
    
    my %seenDomains;
    foreach my $proteinFeature (@{$translation->get_all_ProteinFeatures()}) {
	$self->parseProteinFeature($proteinFeature, $translation, $gusTranslatedAAFeature, $gusTranslatedAASequence, \%seenDomains);
    }
    
    return $gusTranslatedAAFeature;
}

sub parseProteinFeature {
    my ($self, $proteinFeature, $translation, $gusTranslatedAAFeature, $gusTranslatedAASequence, $seenDomains) = @_;

    my $gusTableWriters = $self->getGUSTableWriters();
    my $logicName = $proteinFeature->analysis()->logic_name();

    my @gusFeatures;

    if($logicName eq 'signalp') {
	my $f = GUS::DoTS::SignalPeptideFeature->new($gusTableWriters, $gusTranslatedAASequence);
	push @gusFeatures, $f;
    }
    elsif($logicName eq 'tmhmm') {
	my $f = GUS::DoTS::TransMembraneAAFeature->new($gusTableWriters, $gusTranslatedAASequence);
	push @gusFeatures, $f;
    }
    elsif($logicName eq 'seg') {
	my $f = GUS::DoTS::LowComplexityAAFeature->new($gusTableWriters, $gusTranslatedAASequence);
	push @gusFeatures, $f;
    }
    elsif($logicName =~ /^ms_/) {
	# TODO: mass spec peptides
    }
    elsif($INTERPRO_LOGICS{$logicName}) {
	my $id = $proteinFeature->display_id();
	if($seenDomains->{$id}) {
	    return; # seen before
	}
	$seenDomains->{$id} = 1;
	my @f = $self->parseInterpro($proteinFeature, $gusTranslatedAASequence, $gusTranslatedAAFeature);
	push @gusFeatures, @f; 
    }
    elsif($SKIP_LOGICS{$logicName}) { }
    else {
	die "unrecognized logic $logicName";
    }

    foreach my $gusFeature (@gusFeatures) {
	GUS::DoTS::AALocation->new($gusTableWriters, $proteinFeature, $gusFeature);
    }
    
}

sub parseInterpro {
    my ($self, $interproFeature, $gusTranslatedAASequence, $gusTranslatedAAFeature) = @_;

    my $gusTableWriters = $self->getGUSTableWriters();

    # first make the interpro rows in dbref and domainfeature
    my $interproSecondaryId = $interproFeature->ilabel();
    my $interproPrimaryId = $interproFeature->interpro_ac();

    my $remark = $interproFeature->idesc(); #this is the interpro description used as the dbref remark for both

    # next make the rows in dbref and domain feature for the domaindb
    my $domainPrimaryId = $interproFeature->display_id();
    my $domainSecondaryId = $interproFeature->hdescription();
    my $evalue = $interproFeature->p_value(); # documentation says e value is gotten from p_value methohd

    my $analysis = $interproFeature->analysis();

    my $name =  $analysis->display_label();
    my $version = $analysis->db_version();

    my $interproName = $analysis->program();
    my $interproVersion = $analysis->program_version();

    my ($interproDbRefId, $interproExternalDatabaseReleaseId) = $self->getDbRefAndExternalDatabaseReleaseIds($interproName, $interproVersion, $interproPrimaryId, $interproSecondaryId, $remark);
    my ($domainDbRefId, $domainExternalDatabaseReleaseId) = $self->getDbRefAndExternalDatabaseReleaseIds($name, $version, $domainPrimaryId, $domainSecondaryId, $remark);

    GUS::DoTS::DbRefAAFeature->new($gusTableWriters, $interproDbRefId, $gusTranslatedAAFeature->getPrimaryKey());
    GUS::DoTS::DbRefAAFeature->new($gusTableWriters, $domainDbRefId, $gusTranslatedAAFeature->getPrimaryKey());    

    my $interproDomainFeature = GUS::DoTS::DomainFeature->new($gusTableWriters, $gusTranslatedAASequence, undef, $interproExternalDatabaseReleaseId, $interproPrimaryId, undef);
    my $domainFeature = GUS::DoTS::DomainFeature->new($gusTableWriters, $gusTranslatedAASequence, $interproDomainFeature, $domainExternalDatabaseReleaseId, $domainPrimaryId, $evalue);
    
    return($interproDomainFeature, $domainFeature);
}


sub getDbRefAndExternalDatabaseReleaseIds {
    my ($self, $databaseName, $databaseVersion, $primaryId, $secondaryId, $remark) = @_;

    my $gusTableWriters = $self->getGUSTableWriters();
    
    my $externalDatabaseReleaseId = $self->getExternalDatabaseRelaseFromNameVersion($databaseName, $databaseVersion);    

    my $dbRefNaturalKey = "$primaryId|$secondaryId|$externalDatabaseReleaseId";

    my $dbRefId = $seenDBRefs{$dbRefNaturalKey};

    unless($dbRefId) {
	my $gusDbRef = GUS::SRes::DbRef->new($gusTableWriters, $primaryId, $secondaryId, $remark, $externalDatabaseReleaseId);
	$dbRefId = $gusDbRef->getPrimaryKey();
    }

    return($dbRefId, $externalDatabaseReleaseId);
}


sub getExternalDatabaseRelaseFromNameVersion {
    my ($self, $name, $version) = @_;

    my $gusTableWriters = $self->getGUSTableWriters();
    
    my $externalDatabaseId = $seenExternalDatabases{$name};
    unless($externalDatabaseId) {
	my $externalDatabase = GUS::SRes::ExternalDatabase->new($gusTableWriters, $name);
	$externalDatabaseId = $externalDatabase->getPrimaryKey();
    }

    my $extDbRlsSpec = "$externalDatabaseId|" . $version;
    my $externalDatabaseReleaseId = $seenExternalDatabaseReleases{$extDbRlsSpec};

    unless($externalDatabaseReleaseId) {
	$externalDatabaseReleaseId = GUS::SRes::ExternalDatabaseRelease->new($gusTableWriters, $version, $externalDatabaseId)->getPrimaryKey();
    }

    return $externalDatabaseReleaseId;
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
