package GUS::SRes::EnzymeClass;
use base qw(GUSRow Exporter);

use strict;

our @EXPORT = qw(%seenEnzymeClasses);

our %seenEnzymeClasses;

sub new {
    my $class = shift;

    # this bit calls init
    my $self = $class->SUPER::new(@_);

    my $naturalKey = $self->getNaturalKey();
    $seenEnzymeClasses{$naturalKey} = $self->getPrimaryKey();

    return $self;
}


sub init {
    my ($self, $ecNumber, $externalDatabaseReleaseId) = @_;
    $self->setNaturalKey($ecNumber);
    return {ec_number => $ecNumber,
	    external_database_release_id => $externalDatabaseReleaseId,
	    depth => 0 # we don't care about this here 		
    };
}

1;
