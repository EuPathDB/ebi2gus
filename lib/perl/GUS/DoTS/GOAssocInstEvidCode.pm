package GUS::DoTS::GOAssocInstEvidCode;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $goEvidenceCodeId, $goAssociationInstanceId) = @_;

    return {go_evidence_code_id => $goEvidenceCodeId,
	    go_association_instance_id => $goAssociationInstanceId
    };
}

1;
