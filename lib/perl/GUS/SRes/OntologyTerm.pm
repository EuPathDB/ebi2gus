package GUS::SRes::OntologyTerm;
use base qw(GUSRow Exporter);

use strict;

our @EXPORT = qw(%seenOntologyTerms);

our %seenOntologyTerms;

my %sequenceOntologyMap = (chromosome => 'SO:0000340',
			   polypeptide => 'SO:0000104',
			   exon => 'SO:0000147',
			   mature_transcript => 'SO:0000233',
    );


sub getAltNaturalKey { $_[0]->{_alt_natural_key} }
sub setAltNaturalKey { $_[0]->{_alt_natural_key} = $_[1] }

sub new {
    my $class = shift;

    # this bit calls init
    my $self = $class->SUPER::new(@_);

    my $naturalKey = $self->getNaturalKey();
    my $altNaturalKey = $self->getAltNaturalKey();

    $seenOntologyTerms{$naturalKey} = $self->getPrimaryKey();
    $seenOntologyTerms{$altNaturalKey} = $self->getPrimaryKey() if($altNaturalKey);

    return $self;
}


sub init {
    my ($self, $sourceId, $name, $externalDatabaseReleaseId) = @_;

    die "" unless($externalDatabaseReleaseId);
    
    unless($sourceId) {
	die "required either name or sourceid for ontologyterm" unless($name);

	$sourceId = $sequenceOntologyMap{$name};
	$self->setAltNaturalKey("$name|$externalDatabaseReleaseId");
	die "Could not determine sourceId for name=$name, sourceId=$sourceId" unless($sourceId);    
    }

    $self->setNaturalKey("$sourceId|$externalDatabaseReleaseId");

    return {source_id => $sourceId,
	    external_database_release_id => $externalDatabaseReleaseId,
	    name => $name};

    
}

1;
