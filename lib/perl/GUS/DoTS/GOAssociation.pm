package GUS::DoTS::GOAssociation;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $tableId, $rowId, $goTermId) = @_;

    return {table_id => $tableId,
	    row_id => $rowId,
	    go_term_id => $goTermId,
	    is_not => 0,
	    is_deprecated => 0,
	    defining => 1};
}

1;
