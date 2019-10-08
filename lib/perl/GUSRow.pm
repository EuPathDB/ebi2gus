package GUSRow;

use strict;
use Data::Dumper;


sub getGUSTableWriter { $_[0]->{_gus_table_writer} }
sub setGUSTableWriter { $_[0]->{_gus_table_writer} = $_[1] }

sub getGUSRowAsHash { $_[0]->{_gus_row_hash} }
sub setGUSRowAsHash { $_[0]->{_gus_row_hash} = $_[1] }

sub init { }

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
    $class = uc $class;

    my $gusTableWriter = $gusTableWriters->{$class};

    unless($gusTableWriter) {
	die "Error in setting GUSTableWriter object for class $class";
    }
    
    $self->setGUSTableWriter($gusTableWriter);
    my $row = $self->init(@_);

    $self->setGUSRowAsHash($row);

    return $self;
}

1;
