package GUS::SRes::ExternalDatabase;
use base qw(GUSRow Exporter);

use strict;

our @EXPORT = qw(%seenExternalDatabases);

our %seenExternalDatabases;

sub new {
    my $class = shift;

    # this bit calls init
    my $self = $class->SUPER::new(@_);

    my $naturalKey = $self->getNaturalKey();
    $seenExternalDatabases{$naturalKey} = $self->getPrimaryKey();

    return $self;
}


sub init {
    my ($self, $name) = @_;

    $self->setNaturalKey($name);

    return {name => $name };
}


1;
