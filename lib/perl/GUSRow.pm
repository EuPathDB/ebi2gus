package GUSRow;

use strict;

sub getGUSTableWriter { $_[0]->{_gus_table_writer} }
sub setGUSTableWriter { $_[0]->{_gus_table_writer} = $_[1] }

sub getGUSRowHash { $_[0]->{_gus_row_hash} }
sub setGUSRowHash { $_[0]->{_gus_row_hash} = $_[1] }

sub init { }

sub writeRow {
    my ($self) = @_;

    my $gusTableWriter = $self->getGUSTableWriter();
    my $gusRowAsHash = $self->getGUSRowAsHash();
    $gusTableWriter->writeRow($gusRowAsHash);
}

sub new {
    my $class = shift;
    my $gusTableWriter = shift;

    my $self = bless {}, $class;

    $self->setGUSTableWriter($gusTableWriter);
    my $row = $self->init(@_);

    if($gusTableWriter->isValidRow()) {
	$self->setGUSRow($row);
    }

    return $self;
}

1;
