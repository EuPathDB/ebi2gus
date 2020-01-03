package GUS::DoTS::GOAssociation;
use base qw(GUSRow Exporter);

use strict;

our @EXPORT = qw(%seenGOAssociations);

our %seenGOAssociations;

sub new {
    my $class = shift;

    # this bit calls init
    my $self = $class->SUPER::new(@_);

    my $naturalKey = $self->getNaturalKey();
    $seenGOAssociations{$naturalKey} = $self->getPrimaryKey();

    return $self;
}


sub init {
    my ($self, $tableId, $rowId, $goTermId) = @_;

    my $key = "$tableId|$rowId|$goTermId";
    $self->setNaturalKey($key);
    
    return {table_id => $tableId,
	    row_id => $rowId,
	    go_term_id => $goTermId,
	    is_not => 0,
	    is_deprecated => 0,
	    defining => 1};
}

1;
