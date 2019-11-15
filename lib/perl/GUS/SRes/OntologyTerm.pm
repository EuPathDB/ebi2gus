package GUS::SRes::OntologyTerm;
use base qw(GUSRow Exporter);

use strict;

our @EXPORT = qw(%seenOntologyTerms);

our %seenOntologyTerms;

my %sequenceOntologyMap = (chromosome => 'TODO_1234',
			   polypeptide => 'TODO_1234',
			   exon => 'TODO_1234',
			   mature_transcript => 'TODO_12344',
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
    my ($self, $biotype, $sourceId) = @_;

    my $name;
    unless($sourceId) {
	if(ref $biotype eq "Bio::EnsEMBL::Biotype") {
	    $sourceId = $biotype->so_acc();
	    $name = $biotype->name();
	}
	else {
	    $sourceId = $sequenceOntologyMap{$biotype};
	    $name = $biotype;
	}

	die "Could not determine sourceId for name=$name, sourceId=$sourceId" unless($sourceId);    
    }

    $self->setNaturalKey($sourceId);
    $self->setAltNaturalKey($name) if($name);    
    return {source_id => $sourceId};

    
}

1;
