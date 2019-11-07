package EBIParser;

use strict;

use GUSTableWriter;
use OutputFile;

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

sub parse { }

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


1;
