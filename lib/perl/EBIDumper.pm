package EBIDumper;

use strict;

use GUSTableWriter;

sub getSequences { $_[0]->{_sequences} }
sub setSequences { $_[0]->{_sequences} = $_[1] }

sub getGUSTableWriters { $_[0]->{_gus_table_writers} }
sub setGUSTableWriters { 
    my ($self, $gusTableDefinitionsParser, $outputDirectory) = @_;

    my $tables = $self->getTables();

    my $gusTableWriters = {};
    
    foreach my $className (@$tables) {
	$className =~ s/^GUS:://;
	$className =~ s/::/./;

	$className = uc $className;
	
	my $gusTableDefinition = $gusTableDefinitionsParser->makeTableDefinition($className);

	$gusTableWriters->{$className} = GUSTableWriter->new($gusTableDefinition, $outputDirectory);
    }
    

    $self->{_gus_table_writers} = $gusTableWriters;
}

sub getTables { $_[0]->{_tables} || [] }
sub setTables { $_[0]->{_tables} = $_[1] }

sub new {
    my ($class, $sequences, $gusTableDefinitions, $outputDirectory) = @_;

    my $self = bless {}, $class;

    $self->setSequences($sequences);
    $self->setGUSTableWriters($gusTableDefinitions, $outputDirectory);

    $self->importTableModules();
    
    return $self;
}

sub convert { }

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
