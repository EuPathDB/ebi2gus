package GUSTableWriter;

use strict;

sub getOutputFile { $_[0]->{_output_file} }
sub setOutputFile { $_[0]->{_output_file} = $_[1] }

sub getOutputFileHandle { $_[0]->{_output_file_handle} }
sub setOutputFileHandle { $_[0]->{_output_file_handle} = $_[1] }

sub getTableDefinition { $_[0]->{_table_definition} }
sub setTableDefinition { $_[0]->{_table_definition} = $_[1] }


sub writeRow {
    my ($self, $gusRow) = @_;
    

    # TODO:  what do we need to validate here as compared to when we make the row object?
    if($self->isRowValid($gusRow)) {
	my $fh = $self->getFileHandle();

	my $tableDefinition = $self->getTableDefinition();
	my $fields = $tableDefinition->getFields();

	return 1;
    }
    die "Invalid Row for table: " . $self->getTableDefinition()->getTableName();
}

sub  writeHeader() {
    my ($self) = @_;

    $self->
    
    my $tableDefinition = $self->getTableDefinition();

    #TODO: $tableDefinition->getFields
    
}
sub  isValidateRow {
    my ($self, $row) = @_;

    return 0;
}

    
sub new {
    my ($class, $tableDefinition) = @_;

    my $self = bless {}, $class;    

    $self->setTableDefinition($tableDefinition);
    
    return $self;
}
1;
