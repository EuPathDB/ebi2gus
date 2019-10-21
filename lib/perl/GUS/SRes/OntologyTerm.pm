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


use Data::Dumper;

sub getName { $_[0]->{_name} }
sub setName { $_[0]->{_name} = $_[1] }


sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);

    my $name = $self->getName();
    $seenOntologyTerms{$name} = $self->getPrimaryKey();

    return $self;
}


sub init {
    my ($self, $biotype) = @_;

    my ($sourceId, $name);
    if(ref $biotype eq "Bio::EnsEMBL::Biotype") {
	$sourceId = $biotype->so_acc();
	$name = $biotype->name();
    }
    else {
	$sourceId = $sequenceOntologyMap{$biotype};
	$name = $biotype;
    }

    die "Could not determine sourceId for name=$name, sourceId=$sourceId" unless($sourceId);

    $self->setName($name);
    
    return {source_id => $sourceId,
	    external_database_release_id => "TODO"};
    
}

1;
