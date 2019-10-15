package GUS::SRes::ExternalDatabaseRelease;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $version, $gusExternalDatabase) = @_;

    return {external_database_id => $gusExternalDatabase->getPrimaryKey(),
	    version => $version
    };
}

1;
