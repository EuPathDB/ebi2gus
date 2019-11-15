package GUS::DoTS::GOAssociationInstance;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $goAssociationId, $goAssociationInstanceLoeId) = @_;

    return {go_association_id => $goAssociationId,
	    go_assoc_inst_loe_id => $goAssociationInstanceLoeId,
	    is_primary => 1,
	    is_deprecated => 0
    };
}

1;
