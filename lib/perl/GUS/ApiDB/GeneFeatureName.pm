package GUS::ApiDB::GeneFeatureName;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $geneName, $naFeatureId, $isPreferred, $extDbRlsId) = @_;

    return {na_feature_id => $naFeatureId,
	    name => $geneName,
	    external_database_release_id => $extDbRlsId,
	    is_preferred => $isPreferred,
    };
}

1;
