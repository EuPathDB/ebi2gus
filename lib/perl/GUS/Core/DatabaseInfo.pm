package GUS::Core::DatabaseInfo;
use base qw(GUSRow Exporter);

use strict;

our @EXPORT = qw(%seenDatabases);

our %seenDatabases;

sub new {
    my $class = shift;

    # this bit calls init
    my $self = $class->SUPER::new(@_);

    my $naturalKey = $self->getNaturalKey();
    $seenDatabases{$naturalKey} = $self->getPrimaryKey();

    return $self;
}


sub init {
    my ($self, $name) = @_;

    $self->setNaturalKey($name);
    
    return {name => $name};

    
}

1;
