package EBIParser;

use strict;

use GUSTableWriter;
use OutputFile;

use Data::Dumper;

use Bio::SeqIO;
use Bio::Seq;

use GUS::SRes::OntologyTerm qw(%seenOntologyTerms);
use GUS::SRes::ExternalDatabase qw(%seenExternalDatabases);
use GUS::SRes::ExternalDatabaseRelease qw(%seenExternalDatabaseReleases);
use GUS::SRes::DbRef qw(%seenDBRefs);
use GUS::SRes::EnzymeClass qw(%seenEnzymeClasses);
use GUS::Core::DatabaseInfo qw(%seenDatabases);
use GUS::Core::TableInfo qw(%seenTables);
use GUS::DoTS::GOAssociationInstanceLOE qw(%seenGOEvidences);
use GUS::DoTS::GOAssociation qw(%seenGOAssociations);

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
    return ([
'GUS::DoTS::GeneFeature',
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
	     'GUS::SRes::EnzymeClass',	
	     'GUS::DoTS::AASequenceEnzymeClass',
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
	     'GUS::DoTS::DbRefNAFeature',
	     'GUS::DoTS::DomainFeature',
	     'GUS::Core::ProjectInfo',
	     'GUS::Core::DatabaseInfo',
	     'GUS::Core::TableInfo',
	     'GUS::DoTS::GOAssociation',
	     'GUS::DoTS::GOAssociationInstance',
	     'GUS::DoTS::GOAssociationInstanceLOE',
	     'GUS::DoTS::GOAssocInstEvidCode',
#	     'GUS::DoTS::NAComment',
	    ]);
}

sub getRepeatMaskedIO { $_[0]->{_repeat_masked_io} }
sub setRepeatMaskedIO { $_[0]->{_repeat_masked_io} = $_[1] }
    
sub getSlices { $_[0]->{_slices} }
sub setSlices { $_[0]->{_slices} = $_[1] }

sub getOrganism { $_[0]->{_organism} }
sub setOrganism { $_[0]->{_organism} = $_[1] }

sub getGOSpec { $_[0]->{_go_spec} }
sub setGOSpec { $_[0]->{_go_spec} = $_[1] }

sub getGOEvidSpec { $_[0]->{_go_evid_spec} }
sub setGOEvidSpec { $_[0]->{_go_evid_spec} = $_[1] }

sub getSOSpec { $_[0]->{_so_spec} }
sub setSOSpec { $_[0]->{_so_spec} = $_[1] }

sub getGOExtDbRlsId { $_[0]->{_go_ext_db_rls_id} }
sub setGOExtDbRlsId { $_[0]->{_go_ext_db_rls_id} = $_[1] }

sub getGOEvidExtDbRlsId { $_[0]->{_go_evid_ext_db_rls_id} }
sub setGOEvidExtDbRlsId { $_[0]->{_go_evid_ext_db_rls_id} = $_[1] }


sub getSOExtDbRlsId { $_[0]->{_so_ext_db_rls_id} }
sub setSOExtDbRlsId { $_[0]->{_so_ext_db_rls_id} = $_[1] }

sub getProjectName { $_[0]->{_project_name} }
sub setProjectName { $_[0]->{_project_name} = $_[1] }

sub getProjectRelease { $_[0]->{_project_release} }
sub setProjectRelease { $_[0]->{_project_release} = $_[1] }

sub getRegistry { $_[0]->{_registry} }
sub setRegistry { $_[0]->{_registry} = $_[1] }


sub getGUSTableWriters { $_[0]->{_gus_table_writers} }
sub setGUSTableWriters { 
    my ($self, $gusTableDefinitionsParser, $outputDirectory) = @_;

    my $tables = $self->getTables();

    my $gusTableWriters = {};

    my %outputFiles;
    
    my %allFields;

    foreach my $className (@$tables) {
	$className =~ s/^GUS:://;
	$className =~ s/::/./;

	$className = uc $className;
	
	my $gusTableDefinition = $gusTableDefinitionsParser->makeTableDefinition($className);
	my $realTableName = $gusTableDefinition->getRealTableName();

	my @impFields = $gusTableDefinition->isView() ? keys %{$gusTableDefinition->getImpToViewFieldMap()} : @{$gusTableDefinition->getFields()};

	foreach(@impFields) {
	    $allFields{$realTableName}{$_}++;
	}

	my $outputFile; #Only one fileName/FileHandle/Counter Per RealTableName
	if($outputFiles{$realTableName}) {
	    $outputFile = $outputFiles{$realTableName};
	}
	else {
#	    my $headerFields = $gusTableDefinition->getFields();

	    $outputFile = OutputFile->new($realTableName, $outputDirectory);
	    $outputFiles{$realTableName} = $outputFile;
	}
	
	$gusTableWriters->{$className} = GUSTableWriter->new($gusTableDefinition, $outputFile);
    }

    foreach my $realTableName (keys %outputFiles) {
	my $outputFile = $outputFiles{$realTableName};
	my $impFields = $allFields{$realTableName};
	my @headerFields = keys %$impFields;
	$outputFile->setHeaderFields(\@headerFields);

	$outputFile->writeHeader();
    }

    $self->{_gus_table_writers} = $gusTableWriters;
}

sub new {
    my ($class, $slices, $gusTableDefinitions, $outputDirectory, $organism, $registry, $projectName, $projectRelease, $goSpec, $soSpec, $goEvidSpec) = @_;
    
    my $self = bless {}, $class;

    $self->setSlices($slices);

    $self->setGUSTableWriters($gusTableDefinitions, $outputDirectory);
    $self->setOrganism($organism);

    $self->setProjectName($projectName);
    $self->setProjectRelease($projectRelease);

    $self->setRegistry($registry);
    
    $self->importTableModules();

    $self->setGOSpec($goSpec);
    $self->setGOEvidSpec($goEvidSpec);
    $self->setSOSpec($soSpec);

    my $repeatMaskedFile = "$outputDirectory/blocked.seq";
    my $repeatMaskedIO = Bio::SeqIO->new(-file   => ">$repeatMaskedFile",
					 -format => 'fasta' );

    $self->setRepeatMaskedIO($repeatMaskedIO);
    
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


sub ontologyTermFromBiotypeGeneTranscript {
    my ($self, $biotype, $gusTableWriters, $geneOrTranscript, $isProteinCoding) = @_;

    if($biotype->name() eq 'pseudogene') {
	if($geneOrTranscript eq 'gene') {
	    $biotype->so_acc('SO:0001217'); #protein_coding_gene
	}
#	elsif($geneOrTranscript eq 'gene') {
#	    $biotype->so_acc('SO:0001263'); #ncRNA_gene
#	}
	elsif($geneOrTranscript eq 'transcript') {
	    $biotype->so_acc('SO:0000234'); # mRNA
	}
#	elsif($geneOrTranscript eq 'transcript') {
#	    $biotype->so_acc('SO:0000655'); # ncRNA
#	}
	else {
	    die "geneortranscript must be either gene or transcript";
	}
    }
    return $self->ontologyTermFromBiotype($biotype, $gusTableWriters);
}

sub ontologyTermFromBiotype {
    my ($self, $biotype, $gusTableWriters) = @_;

    my $name = $biotype->name();
    my $sourceId = $biotype->so_acc();
    my $soExtDbRlsId =  $self->getSOExtDbRlsId();
    
    if($seenOntologyTerms{"$sourceId|$soExtDbRlsId"}) {
	return $seenOntologyTerms{"$sourceId|$soExtDbRlsId"};
    }

    return GUS::SRes::OntologyTerm->new($gusTableWriters, $sourceId, $name, $soExtDbRlsId)->getPrimaryKey();
}

sub ontologyTermFromName {
    my ($self, $name, $gusTableWriters) = @_;

    my $soExtDbRlsId =  $self->getSOExtDbRlsId();

    if($seenOntologyTerms{"$name|$soExtDbRlsId"}) {
	return $seenOntologyTerms{"$name|$soExtDbRlsId"};
    }

    return GUS::SRes::OntologyTerm->new($gusTableWriters, undef, $name, $soExtDbRlsId)->getPrimaryKey();
}


sub ontologyTermFromEvidenceCode {
    my ($self, $evidenceCode, $gusTableWriters) = @_;

    my $goEvidExtDbRlsId =  $self->getGOEvidExtDbRlsId();
    
    if($seenOntologyTerms{"$evidenceCode|$goEvidExtDbRlsId"}) {
	return $seenOntologyTerms{"$evidenceCode|$goEvidExtDbRlsId"};
    }

    return GUS::SRes::OntologyTerm->new($gusTableWriters, $evidenceCode, $evidenceCode, $goEvidExtDbRlsId)->getPrimaryKey();
}


sub ontologyTermFromGOTerm {
    my ($self, $goTerm, $gusTableWriters) = @_;

    $goTerm =~ s/:/_/;

    my $goExtDbRlsId =  $self->getGOExtDbRlsId();
    
    if($seenOntologyTerms{"$goTerm|$goExtDbRlsId"}) {
	return $seenOntologyTerms{"$goTerm|$goExtDbRlsId"};
    }

    return GUS::SRes::OntologyTerm->new($gusTableWriters, $goTerm, $goTerm, $goExtDbRlsId)->getPrimaryKey();
}


sub dumpRepeatMaskedSeq {
    my ($self, $slice, $externalNaSeq) = @_;

    my $io = $self->getRepeatMaskedIO();

    my $sequenceSourceId = $externalNaSeq->getGUSRowAsHash()->{source_id};

    my $repeatMaskedSlice = $slice->get_repeatmasked_seq();
    $repeatMaskedSlice->soft_mask(1);

    my $repeatMaskedSeq = $repeatMaskedSlice->seq();

    my $seq = Bio::Seq->new(-display_id => $sequenceSourceId,
			    -seq => $repeatMaskedSeq);
    
    $io->write_seq($seq);
}


sub parseSlice {
    my ($self, $slice, $gusExternalDatabaseRelease, $gusTaxon) = @_;



    my $gusTableWriters = $self->getGUSTableWriters();

    my $gusSequenceOntologyId = $self->ontologyTermForSlice($slice, $gusTableWriters);

    my $organismAbbrev = $self->getOrganism()->getOrganismAbbrev();

    my $insdcSynonym;

    foreach my $sliceSynonym (@{$slice->get_all_synonyms()}) {
	$insdcSynonym = $sliceSynonym->name() if($sliceSynonym->dbname() eq "INSDC");
    }
    
    my $gusExternalNASequence = GUS::DoTS::ExternalNASequence->new($gusTableWriters, $slice, $gusTaxon, $gusExternalDatabaseRelease, $gusSequenceOntologyId, $insdcSynonym, $organismAbbrev);

    $self->dumpRepeatMaskedSeq($slice, $gusExternalNASequence);

    
    my %transcriptXrefsLogics;
    my %geneXrefsLogics;
    my %translationXrefsLogics;    

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
    elsif($logicName =~ /^repeatmask/) {
	$gusFeature = GUS::DoTS::Repeats->new($gusTableWriters, $repeatFeature, $gusExternalNASequence, $gusExternalDatabaseRelease);		
    }
    else {
	return;
    }

    GUS::DoTS::NALocation->new($gusTableWriters, $repeatFeature, $gusFeature);
}

sub parseGene {
    my ($self, $gene, $gusExternalDatabaseRelease, $gusTaxon, $gusExternalNASequence) = @_;
    
    my $gusTableWriters = $self->getGUSTableWriters();

    my $isProteinCoding;
    foreach(@{ $gene->get_all_Transcripts() }) {
	if($_->translation()) {
	    $isProteinCoding = 1;
	    last;
	}
    }
    
    my $geneSequenceOntologyId = $self->ontologyTermFromBiotypeGeneTranscript($gene->get_Biotype(), $gusTableWriters, 'gene', $isProteinCoding);
    # TODO: product name
    my $gusGeneFeature = GUS::DoTS::GeneFeature->new($gusTableWriters, $gene, $gusExternalNASequence, $gusExternalDatabaseRelease, $geneSequenceOntologyId);
    my $gusGeneNALocation = GUS::DoTS::NALocation->new($gusTableWriters, $gene, $gusGeneFeature);

    my $taxonId = $gusTaxon->getPrimaryKey();
    
    my %exonMap;
    my $exonSequenceOntologyId = $self->ontologyTermFromName("exon", $gusTableWriters);
    foreach my $exon ( @{ $gene->get_all_Exons() } ) {
	my $gusExonFeature = GUS::DoTS::ExonFeature->new($gusTableWriters, $exon, $gusGeneFeature, $gusExternalDatabaseRelease, $exonSequenceOntologyId);
	my $gusExonNALocation = GUS::DoTS::NALocation->new($gusTableWriters, $exon, $gusExonFeature);

	my $exonKey = $exon->start()."-".$exon->end()."-".$exon->strand()."-".$exon->phase()."-".$exon->end_phase();
	$exonMap{$exonKey} = $gusExonFeature->getPrimaryKey();
    }
    
    foreach my $transcript ( @{ $gene->get_all_Transcripts() } ) {
	$self->parseTranscript($transcript, $gene, $gusGeneFeature, $taxonId, \%exonMap, $gusExternalDatabaseRelease);
    }

    foreach my $xref (@{$gene->get_all_object_xrefs()}) {
	my $databaseName = $xref->dbname();
	my $databaseVersion = $xref->analysis()->logic_name();

	my $primaryId = $xref->primary_id();
	
	my ($dbRefId, $externalDatabaseReleaseId) = $self->getDbRefAndExternalDatabaseReleaseIds($databaseName, $databaseVersion, $primaryId, undef, undef);
	GUS::DoTS::DbRefNAFeature->new($gusTableWriters, $dbRefId, $gusGeneFeature->getPrimaryKey());
    }
}



sub parseTranscript {
    my ($self, $transcript, $gene, $gusGeneFeature, $taxonId, $exonMap, $gusExternalDatabaseRelease) = @_;

    my $gusTableWriters = $self->getGUSTableWriters();

    my $splicedNASequenceOntologyId = $self->ontologyTermFromName("mature_transcript", $gusTableWriters);
    my $gusSplicedNASequence = GUS::DoTS::SplicedNASequence->new($gusTableWriters, $transcript, $taxonId, $gusExternalDatabaseRelease, $splicedNASequenceOntologyId);

    my $translation = $transcript->translation();

    my $isProteinCoding = $transcript ? 1 : 0;
    
    my $transcriptSequenceOntologyId = $self->ontologyTermFromBiotypeGeneTranscript($transcript->get_Biotype(), $gusTableWriters, 'transcript', $isProteinCoding);
    
    # add Product name
    my $gusTranscript = GUS::DoTS::Transcript->new($gusTableWriters, $transcript, $gusGeneFeature, $gusSplicedNASequence, $gusExternalDatabaseRelease, $transcriptSequenceOntologyId);
    my $gusTranscriptNALocation = GUS::DoTS::NALocation::Transcript->new($gusTableWriters, $gusTranscript, $gusSplicedNASequence);

    my $geneType = $gene->get_Biotype()->name();

    my ($gusTranslatedAAFeature, $gusTranslatedAASequence);

    if($translation) {
	($gusTranslatedAAFeature, $gusTranslatedAASequence) = $self->parseTranslation($translation, $transcript, $gusTranscript, $taxonId, $gusExternalDatabaseRelease);
    }

    my $exonOrderNum = 1;
    foreach my $exon ( @{ $transcript->get_all_Exons() } ) {
	my $exonKey = $exon->start()."-".$exon->end()."-".$exon->strand()."-".$exon->phase()."-".$exon->end_phase();
	
	my $gusExonId = $exonMap->{$exonKey};
	    
	GUS::DoTS::RNAFeatureExon->new($gusTableWriters, $gusExonId, $gusTranscript, $exonOrderNum);

	if($translation) {
	    my $codingRegionStart = $exon->coding_region_start($transcript);
	    my $codingRegionEnd = $exon->coding_region_end($transcript);
	    # doesn't make a lot of sense but we add a row here even if the 
	    GUS::DoTS::AAFeatureExon->new($gusTableWriters, $gusTranslatedAAFeature, $gusExonId, $codingRegionStart, $codingRegionEnd);		    
	}
	$exonOrderNum++;
    }


    foreach my $xref(@{$transcript->get_all_object_xrefs()}) {
	my $databaseName = $xref->dbname();
	if($databaseName eq "GO") {
	    $self->parseGOAssociation($gusTranslatedAASequence, $xref)
	}
	else {
	    my $databaseVersion = $xref->analysis()->logic_name();
	    my $primaryId = $xref->primary_id();

	    my ($dbRefId, $externalDatabaseReleaseId) = $self->getDbRefAndExternalDatabaseReleaseIds($databaseName, $databaseVersion, $primaryId, undef, undef);
	    GUS::DoTS::DbRefNAFeature->new($gusTableWriters, $dbRefId, $gusTranscript->getPrimaryKey());
	}
    }
}

sub parseGOAssociation {
    my ($self, $gusTranslatedAASequence, $xref) = @_;

    my $proteinDatabaseName = "DoTS";
    my $proteinTableName = "TranslatedAASequence";
    
    my $gusTableWriters = $self->getGUSTableWriters();

    my $proteinDatabaseId = $seenDatabases{$proteinDatabaseName} ? $seenDatabases{$proteinDatabaseName} : GUS::Core::DatabaseInfo->new($gusTableWriters, $proteinDatabaseName)->getPrimaryKey();

    my $proteinTableKey = "$proteinTableName|$proteinDatabaseId";
    my $proteinTableId = $seenTables{$proteinTableKey} ? $seenTables{$proteinTableKey} : GUS::Core::TableInfo->new($gusTableWriters, $proteinTableName, $proteinDatabaseId)->getPrimaryKey();
    
    my $goId = $xref->display_id();
    my $gusGOTermId = $self->ontologyTermFromGOTerm($goId, $gusTableWriters);

    my $goAssociationKey = $proteinTableId . "|" . $gusTranslatedAASequence->getPrimaryKey() . "|" . $gusGOTermId;
    my $goAssociationId = $seenGOAssociations{$goAssociationKey};
    unless($goAssociationId) {
	$goAssociationId = GUS::DoTS::GOAssociation->new($gusTableWriters, $proteinTableId, $gusTranslatedAASequence->getPrimaryKey(), $gusGOTermId)->getPrimaryKey();
    }


    my $loeName = ref($xref) eq 'Bio::EnsEMBL::OntologyXref' ? $xref->analysis()->logic_name() : $xref->db();
    my $goEvidenceLoeId = $seenGOEvidences{$loeName};
    unless($goEvidenceLoeId) {
	$goEvidenceLoeId = GUS::DoTS::GOAssociationInstanceLOE->new($gusTableWriters, $loeName)->getPrimaryKey();
    }

    my $gusGoAssociationInstance = GUS::DoTS::GOAssociationInstance->new($gusTableWriters, $goAssociationId, $goEvidenceLoeId);

    foreach my $linkageType (@{$xref->get_all_linkage_types()}) {
	my $evidenceCodeId = $self->ontologyTermFromEvidenceCode($linkageType, $gusTableWriters);
	GUS::DoTS::GOAssocInstEvidCode->new($gusTableWriters, $evidenceCodeId, $gusGoAssociationInstance->getPrimaryKey());
    }
}


sub parseTranslation {
    my ($self, $translation, $transcript, $gusTranscript, $taxonId, $gusExternalDatabaseRelease) = @_;

    
    my $gusTableWriters = $self->getGUSTableWriters();
    
    my $translatedAASequenceOntologyId = $self->ontologyTermFromName("polypeptide", $gusTableWriters);
    my $gusTranslatedAASequence = GUS::DoTS::TranslatedAASequence->new($gusTableWriters, $transcript, $taxonId, $gusExternalDatabaseRelease, $translatedAASequenceOntologyId);

    GUS::ApiDB::AaSequenceAttribute->new($gusTableWriters, $translation, $gusTranslatedAASequence);

    my $gusTranslatedAAFeature = GUS::DoTS::TranslatedAAFeature->new($gusTableWriters, $transcript, $gusTranslatedAASequence, $gusTranscript, $gusExternalDatabaseRelease);
    
    my %seenDomains;
    foreach my $proteinFeature (@{$translation->get_all_ProteinFeatures()}) {
	$self->parseProteinFeature($proteinFeature, $translation, $gusTranslatedAAFeature, $gusTranslatedAASequence, \%seenDomains);
    }

    foreach my $xref (@{$translation->get_all_object_xrefs()}) {
	my $databaseName = $xref->dbname();
	my $databaseVersion = $xref->analysis()->logic_name();

	my $primaryId = $xref->primary_id();
	
	my ($dbRefId, $externalDatabaseReleaseId) = $self->getDbRefAndExternalDatabaseReleaseIds($databaseName, $databaseVersion, $primaryId, undef, undef);
	GUS::DoTS::DbRefAAFeature->new($gusTableWriters, $dbRefId, $gusTranslatedAAFeature->getPrimaryKey());

	if($databaseName eq 'KEGG_Enzyme') {
	    $self->parseKeggEnzyme($primaryId, $gusTranslatedAASequence->getPrimaryKey(), $databaseName);
	}
	
    }
    
    return($gusTranslatedAAFeature, $gusTranslatedAASequence);
}


sub parseKeggEnzyme {
    my ($self, $keggEnzyme, $gusAASequenceId, $databaseName) = @_;

    my $gusTableWriters = $self->getGUSTableWriters();
    
    my @ecNumbers = split(/\+/, $keggEnzyme);
    shift @ecNumbers; # remove the first bit which is not an ec number

    foreach my $ec (@ecNumbers) {
	my $gusEnzymeClassId = $seenEnzymeClasses{$ec};
	unless($gusEnzymeClassId) {
	    $gusEnzymeClassId = GUS::SRes::EnzymeClass->new($gusTableWriters, $ec)->getPrimaryKey();
	}

	GUS::DoTS::AASequenceEnzymeClass->new($gusTableWriters, $gusAASequenceId, $gusEnzymeClassId, $databaseName)->getPrimaryKey();
    }
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

    my $interproDomainFeature = GUS::DoTS::DomainFeature->new($gusTableWriters, $gusTranslatedAASequence, undef, $interproExternalDatabaseReleaseId, $interproPrimaryId, undef);
    my $domainFeature = GUS::DoTS::DomainFeature->new($gusTableWriters, $gusTranslatedAASequence, $interproDomainFeature, $domainExternalDatabaseReleaseId, $domainPrimaryId, $evalue);

    GUS::DoTS::DbRefAAFeature->new($gusTableWriters, $interproDbRefId, $interproDomainFeature->getPrimaryKey());
    GUS::DoTS::DbRefAAFeature->new($gusTableWriters, $domainDbRefId, $domainFeature->getPrimaryKey());    

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

    my $gusTableWriters = $self->getGUSTableWriters();
    
    my $projectName = $self->getProjectName();
    my $projectRelease = $self->getProjectRelease();
    my $gusProjectInfo = GUS::Core::ProjectInfo->new($gusTableWriters, $projectName, $projectRelease);

    my $goSpec = $self->getGOSpec();
    my $goEvidSpec = $self->getGOEvidSpec();
    my $soSpec = $self->getSOSpec();

    my $goExtDbRlsId = $self->getExternalDatabaseRelaseFromSpec($goSpec);
    my $goEvidExtDbRlsId = $self->getExternalDatabaseRelaseFromSpec($goEvidSpec);
    my $soExtDbRlsId = $self->getExternalDatabaseRelaseFromSpec($soSpec);

    $self->setGOExtDbRlsId($goExtDbRlsId);
    $self->setGOEvidExtDbRlsId($goEvidExtDbRlsId);
    $self->setSOExtDbRlsId($soExtDbRlsId);
    
    my $topLevelSlices = $self->getSlices();
    my $organism = $self->getOrganism();
    
    my $gusTaxon = GUS::SRes::Taxon->new($gusTableWriters, $organism);

    my $gusExternalDatabaseRelease = $self->getExternalDatabaseRelease($gusTableWriters, $organism);
    
    foreach my $slice (@$topLevelSlices) {
	$self->parseSlice($slice, $gusExternalDatabaseRelease, $gusTaxon);
    }
}

sub getExternalDatabaseRelaseFromSpec {
    my ($self, $spec) = @_;
    my ($name, $version) = split(/\|/, $spec);
    return $self->getExternalDatabaseRelaseFromNameVersion($name, $version);
}



1;
