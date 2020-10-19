package GUS::SRes::ExternalDatabaseRelease;
use base qw(GUSRow Exporter);

use strict;

our @EXPORT = qw(%seenExternalDatabaseReleases);

our %seenExternalDatabaseReleases;

sub new {
    my $class = shift;

    # this bit calls init
    my $self = $class->SUPER::new(@_);

    my $naturalKey = $self->getNaturalKey();
    $seenExternalDatabaseReleases{$naturalKey} = $self->getPrimaryKey();

    return $self;
}


sub init {
    my ($self, $version, $externalDatabaseId, $idType) = @_;

    my $naturalKey = "$externalDatabaseId|$version";
    $self->setNaturalKey($naturalKey);
    
    return {external_database_id => $externalDatabaseId,
	    version => $version,
	    id_type => $idType,
    };
}


1;
