package GUS::SRes::DbRef;
use base qw(GUSRow Exporter);

use strict;

our @EXPORT = qw(%seenDBRefs);

our %seenDBRefs;

sub new {
    my $class = shift;

    # this bit calls init
    my $self = $class->SUPER::new(@_);

    my $naturalKey = $self->getNaturalKey();
    $seenDBRefs{$naturalKey} = $self->getPrimaryKey();

    return $self;
}


sub init {
    my ($self, $primaryId, $secondaryId, $remark, $gusExternalDatabaseReleaseId) = @_;

    my $naturalKey = "$primaryId|$secondaryId|$gusExternalDatabaseReleaseId";

    $self->setNaturalKey($naturalKey);

    return {external_database_release_id => $gusExternalDatabaseReleaseId,
	    primary_identifier => $primaryId,
	    secondary_identifier => $secondaryId,
	    remark => $remark,
    };
}

1;
