package GUSRow;

use strict;

use GUS::Core::ProjectInfo qw($projectId);

sub getGUSTableWriter { $_[0]->{_gus_table_writer} }
sub setGUSTableWriter { $_[0]->{_gus_table_writer} = $_[1] }

sub getGUSRowAsHash { $_[0]->{_gus_row_hash} }
sub setGUSRowAsHash { $_[0]->{_gus_row_hash} = $_[1] }

sub getNaturalKey { $_[0]->{_natural_key} }
sub setNaturalKey { $_[0]->{_natural_key} = $_[1] }

sub init { }

sub getPrimaryKey { $_[0]->{_primary_key} }
sub setPrimaryKey { $_[0]->{_primary_key} = $_[1] }

sub nextPk {
    my ($self) = @_;

    return $self->getGUSTableWriter()->getOutputFile()->nextPk();
}

sub writeRow {
    my ($self) = @_;

    my $gusTableWriter = $self->getGUSTableWriter();
    my $gusRowAsHash = $self->getGUSRowAsHash();
    $gusTableWriter->writeRow($gusRowAsHash);
}

sub new {
    my $class = shift;
    my $gusTableWriters = shift;

    my $self = bless {}, $class;

    $class =~ s/^GUS:://;
    $class =~ s/::/./;
    $class =~ s/::.*//;
    $class = uc $class;

    my $gusTableWriter = $gusTableWriters->{$class};
    
    unless($gusTableWriter) {
	die "Error in setting GUSTableWriter object for class $class";
    }
    
    $self->setGUSTableWriter($gusTableWriter);

    my $primaryKey = $self->nextPk();
    $self->setPrimaryKey($primaryKey);

    my $row = $self->init(@_);

    # overide the primarykey value here in case 
    my $primaryKeyField = $gusTableWriter->getTableDefinition()->getPrimaryKeyField();
    
    $row->{$primaryKeyField} = $primaryKey;
    $row->{row_project_id} = $projectId if($projectId);

    $self->setGUSRowAsHash($row);
    
    $self->writeRow();
    
    return $self;
}

1;
