package GUSTableWriter;

use strict;

sub getOutputFile { $_[0]->{_output_file} }
sub setOutputFile { $_[0]->{_output_file} = $_[1] }

sub getTableDefinition { $_[0]->{_table_definition} }
sub setTableDefinition { $_[0]->{_table_definition} = $_[1] }

sub writeRow {
    my ($self, $gusRow) = @_;

    # TODO:  what do we need to validate here as compared to when we make the row object?
    # IF nothing... should remove this if
    if($self->isRowValid($gusRow)) {
	my $outputFile = $self->getOutputFile();

	my $tableDefinition = $self->getTableDefinition();
	my $impToViewFieldMap = $tableDefinition->getImpToViewFieldMap();
	
	$outputFile->writeRow($impToViewFieldMap, $gusRow);
	return 1;
    }
    die "Invalid Row for table: " . $self->getTableDefinition()->getName();
}


# rows are always valid for now
sub  isRowValid {
    my ($self, $row) = @_;

    return 1;
}

    
sub new {
    my ($class, $tableDefinition, $outputFile) = @_;

    my $self = bless {}, $class;    

    $self->setTableDefinition($tableDefinition);
    $self->setOutputFile($outputFile);
    
    return $self;
}

1;
