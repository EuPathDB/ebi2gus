package GUS::Core::TableInfo;
use base qw(GUSRow Exporter);

use strict;

our @EXPORT = qw(%seenTables);

our %seenTables;

sub new {
    my $class = shift;

    # this bit calls init
    my $self = $class->SUPER::new(@_);

    my $naturalKey = $self->getNaturalKey();
    $seenTables{$naturalKey} = $self->getPrimaryKey();

    return $self;
}


sub init {
    my ($self, $name, $databaseId) = @_;

    $self->setNaturalKey("$name|$databaseId");
    
    return {name => $name,
	    is_versioned => "",
	    is_updatable => "",
	    table_type => "",
	    is_view => "",
	    database_id => $databaseId};
}

1;
